# TM-NoC
This project implements a custom **2D mesh Network-on-Chip (NoC)** architecture named **TM NoC**, designed in SystemVerilog. The design focuses on the **router microarchitecture** and evaluates routing performance under various traffic workloads.

## Features

- 2D Mesh Topology with X-Y routing
- 5-Port Router (North, South, East, West, Local)
- Modular Input/Output Units with FSM-based control
- Packet-switched design with Head, Body, Tail flits (19-bit wide)
- Traffic Generator for custom workload injection and measurement
- Round-robin switch arbiter and flow control logic

## Evaluation Metrics

- **Zero-load Latency**
- **Throughput under synthetic workloads**
- **Execution time across communication patterns**

All evaluations are performed on a 4×4 mesh using Vivado simulation.

## Documentation

For detailed design explanation, implementation decisions, and evaluation results, see the full paper:

📄 [TM_NoC_IEEE.pdf](TM-NoC/doc/TM_NoC_IEEE.pdf)

## Context

This project was developed as part of the course **02211 Research Topics in Computer Architecture**, Spring 2025, at **DTU (Technical University of Denmark)**.

## Future Work

- Adaptive routing algorithms
- Virtual channels and HOL blocking mitigation
- Network Interface (NI) design
- Enhanced buffering strategies

## License

This project is open-source for academic and research purposes.

