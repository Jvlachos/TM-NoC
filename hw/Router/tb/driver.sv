import router_pkg::*;
class driver;
    virtual TbBusInt.DRIVER tbBusVif;
    mailbox        gen2driv;
    reference_model refmod;
    int            no_transactions;
    `define DRIV_IF tbBusVif.driver_cb
    transaction pending_q[$];

    function new(virtual TbBusInt tbBusVif, mailbox gen2driv, reference_model refmod);
        this.tbBusVif = tbBusVif;
        this.gen2driv = gen2driv;
        this.refmod   = refmod;
    endfunction

    task reset;
        wait(~tbBusVif.reset_n);
        $display("------[DRIVER]: Reset Started ------\n");
        `DRIV_IF.start <= 0;
        `DRIV_IF.flits <= '{default:'0};
        `DRIV_IF.tb_flit_request <= '{default:'0};
        `DRIV_IF.out_addrs  <= '{default:'0};
        wait(tbBusVif.reset_n);
        $display("------[DRIVER]: Reset Ended ------\n");
    endtask;

    task request_thread();
        transaction trans;
        int x, y;
        forever begin
            gen2driv.get(trans);
            x = unsigned'(trans.tg_xaddr);
            y = unsigned'(trans.tg_yaddr);
            pending_q.push_back(trans);
            refmod.register_transaction(trans);
            @(posedge tbBusVif.clk);
            no_transactions ++;
        end
    endtask

    task drive_packet_thread(transaction trans);
        int x = unsigned'(trans.tg_xaddr);
        int y = unsigned'(trans.tg_yaddr);
        @(posedge tbBusVif.clk);
        foreach(trans.flits[j]) begin
         //$display("driving %h to (%d,%d)",trans.flits[j].flit,x,y);
            `DRIV_IF.flits[y][x] <= trans.flits[j];
            @(posedge tbBusVif.clk);
        end
       `DRIV_IF.flits[y][x] <= '0;
       `DRIV_IF.tb_flit_request[y][x] <= 0;
       `DRIV_IF.out_addrs[y][x].xaddr <= 0;
       `DRIV_IF.out_addrs[y][x].yaddr <= 0;
    endtask

    task ack_thread();
        transaction trans;
        int x,y;
        logic ack_seen[ROWS][COLUMNS];
        forever begin
            @(posedge tbBusVif.clk);
            foreach(pending_q[i]) begin
                trans = pending_q[i];
                x = unsigned'(trans.tg_xaddr);
                y = unsigned'(trans.tg_yaddr);
             
            `DRIV_IF.tb_flit_request[y][x] <= 1;
            `DRIV_IF.out_addrs[y][x].xaddr <= x;
            `DRIV_IF.out_addrs[y][x].yaddr <= y;
            //$display("[Driver] :Pending  x :%d, y :%d\n", x, y);
                if (`DRIV_IF.tb_flit_ack[y][x] && !ack_seen[y][x]) begin
                    trans.flit_ack <= 1;
                    ack_seen[y][x] = 1;
                //$display("[Driver] :Got ack from x :%d, y :%d\n", x, y);
                    pending_q.delete(i);
                    drive_packet_thread(trans);
                end
                for (int k = 0; k < ROWS; k++)
                    for (int x = 0; x < COLUMNS; x++)
                        if (!`DRIV_IF.tb_flit_ack[k][x])
                            ack_seen[k][x] = 0;
            end
        end
    endtask

    task drive;
        `DRIV_IF.start <= 1;
        fork
            request_thread();
            ack_thread();
        join_none
    endtask
endclass