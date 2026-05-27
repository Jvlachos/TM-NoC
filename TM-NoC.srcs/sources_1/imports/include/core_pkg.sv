
`timescale 1ns/1ps
package core;
    
    typedef enum  logic [1:0] { 
        BRANCH_PRFX = 2'b00,
        ARITHM_PRFX = 2'b01,
        J_PRFX      = 2'b10
    } alu_prefix_t;

    typedef enum  logic {
        LOAD_PRFX  = 1'b0,
        STORE_PRFX = 1'b1
    } mem_prefix_t;

    typedef enum logic [4:0] 
    {
        ALU_BEQ         = 5'b00000,
        ALU_BNE         = 5'b00001,
        ALU_LUI         = 5'b00010,
        ALU_BLT         = 5'b00100,
        ALU_BGE         = 5'b00101,
        ALU_BLTU        = 5'b00110,
        ALU_BGEU        = 5'b00111,
        ALU_ADD         = 5'b01000, 
        ALU_SLL         = 5'b01001, 
        ALU_SLT         = 5'b01010,
        ALU_SLTU        = 5'b01011,
        ALU_XOR         = 5'b01100,
        ALU_SRA_SRL     = 5'b01101,
        ALU_OR          = 5'b01110,
        ALU_AND         = 5'b01111,
        ALU_AUIPC       = 5'b10000,
        ALU_JAL         = 5'b10001,
        ALU_JALR        = 5'b10010,
        ALU_NOP         = 5'b11111  
    } ALU_OP_t;

    typedef enum logic [2:0]{
        I_FORMAT = 3'b000,
        R_FORMAT = 3'b001,
        U_FORMAT = 3'b010,
        S_FORMAT = 3'b011,
        B_FORMAT = 3'b100,
        J_FORMAT = 3'b101,
        NOP      = 3'b111
    } formats_t ;

    typedef enum logic [3:0]{
        LB = 4'b0000,
        LH = 4'b0001,
        LW = 4'b0010,
        LBU= 4'b0100,
        LHU= 4'b0101,
        SB = 4'b1000,
        SH = 4'b1001,
        SW = 4'b1010,
        MEM_NOP= 4'b1111
    } MEM_OP_t;


    localparam BUS_DYN_BITS = $bits(MEM_OP_t) + $bits(ALU_OP_t) + $bits(formats_t);
    localparam DEPTH = 4096 ;
    localparam ADDR_WIDTH = $clog2(DEPTH);
    localparam DATA_WIDTH =32;
    localparam DATA_BYTES = DATA_WIDTH/8;
    localparam MEM_OP_BITS = $bits(MEM_OP_t);

    typedef struct packed {
        logic [31:0] i_addr;
        logic [31:0] target_addr;
    } btb_entry_t;



    typedef struct packed {
        MEM_OP_t mem_op;
        ALU_OP_t alu_op;
        formats_t format;
        bit is_branch;
        logic [31:0] instr;
        logic [31:0] imm;
        logic [4:0] rs1;
        logic [4:0] rs2;
        logic [4:0] rd;
        logic [31:0] rd_res;
        logic [31:0] rs1_data;
        logic [31:0] rs2_data;
        logic [31:0] pc;
        logic [31:0] mem_addr;
        logic [31:0] mem_w_data;
        logic [DATA_BYTES-1:0] mem_w_en;
        bit rf_wr_en;
        bit pipeline_stall;
        bit prediction;
        btb_entry_t btb_entry;
    } pipeline_bus_t;

    localparam BUS_BITS = $bits(pipeline_bus_t);
    typedef struct packed {
        bit is_taken;
        logic [31:0] branch_target;
        logic [31:0] i_addr;
        bit mispredict;
        logic [31:0] mispredict_target;
    } br_cntrl_bus_t;

    typedef struct packed {
        logic [DATA_BYTES-1:0] write_en;
        MEM_OP_t mem_op;
        logic [31:0] addr;
        logic [31:0] r_data;
        logic [31:0] w_data;
        logic [4:0]  mem_rd;
    } mem_cntrl_bus_t;
    
    typedef enum logic [1:0] {
        NONE_STAGE = 2'b00,  
        MEM_STAGE  = 2'b01,
        WB_STAGE   = 2'b10,
        WBLATE_STAGE  = 2'b11
     } fw_stages_t;

    typedef enum logic [1:0]{
        RS_NONE = 2'b00,
        RS1     = 2'b01,
        RS2     = 2'b10,
        RS1_RS2 = 2'b11
    }fw_regs_t;

    typedef struct packed {
        fw_stages_t stage;
        fw_regs_t regs;
        fw_stages_t rs1;
        fw_stages_t rs2;
        logic [4:0] rs1_addr;
        logic [4:0] rs2_addr;
    } fw_cntrl_bus_t;

    typedef struct packed {
        logic [4:0]  rd_addr;
        logic [31:0] rd;
    } bypass_bus_t;
 
        localparam BTB_ENTRY_SIZE = $bits(btb_entry_t);
    localparam BTB_SIZE       = 4096;
    localparam GHR_SIZE         = 8;
    localparam COUNTER_TABLE_SZ = 4096;
    localparam COUNTER_BITS     = 2;
    
    typedef enum logic[COUNTER_BITS-1:0] {
        STRONGLY_NOT_TAKEN = 2'b00,
        WEAKLY_NOT_TAKEN   = 2'b01,
        WEAKLY_TAKEN       = 2'b10,
        STRONGLY_TAKEN     = 2'b11
    } cntr_pattern_t;


    typedef struct packed {
        cntr_pattern_t counter;
    } cntr_table_entry_t;

    typedef struct packed {
        logic [GHR_SIZE-1:0] GHR;
    } GHR_t;

    localparam GHR_SELECT = 8;
    
    localparam PC_SELECT  = 4;
    localparam COUNTER_TABLE_BITS = $clog2(COUNTER_TABLE_SZ);
    
    

    typedef struct packed {
        logic [31:0] mispredictions;
        logic [31:0] no_conditional;
        logic [31:0] no_jumps;

    } br_metrics_t;

    typedef struct packed {
        br_metrics_t br_metrics;
        logic [31:0] total_ins;
    } metrics_t;
        
    
  endpackage