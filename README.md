# Single-Cycle RV32I Processor (SystemVerilog)

A modular single-cycle RV32I core built to the interfaces and behavior in the supplied course specification. Implemented instructions cover the RV32I base integer datapath except FENCE, ECALL, EBREAK and CSR instructions. Instruction and data memories are external to the core.

## Architecture

- Fetch: `if_stage` — asynchronous-reset PC, sequential PC+4, branch/jump selection, stall.
- Decode: `decoder`, `imm_generator`, `register_file`, `main_control`, `id_stage`.
- Execute: `alu`, `alu_control`, `ex_stage`.
- Writeback: `wb_stage`.
- Integration: `single_cycle_riscv`.

The core ports are exactly those specified in `Single_Cycle_RISCV/README.md`. `address` drives external instruction memory; `alu_out` is the data-memory address; `rs2_data`, `mem_write`, `mem_read`, and `fn3` are data-memory controls/data.

## Important behavior

- PC asynchronously resets high to `32'h80000000`.
- `stall` holds the PC and prevents register-file writes.
- Register file has asynchronous active-high reset and clears all 32 entries with a `for` loop. x0 always reads zero and cannot be written.
- Branch condition is reported on the ALU `zero` output only for branch ALU operations.
- JAL/JALR write PC+4; LUI writes the upper immediate; AUIPC writes PC+upper immediate.
- JALR target clears bit zero.
- No gated clocks, register initial values, or SystemVerilog assignment-pattern register clears are used.

## Repository layout

Each module is in the path expected by the course template:

```text
IF_Stage/rtl.sv
Decoder/rtl.sv
Immediate_Generator/rtl.sv
Register_File/rtl.sv
Main_Control/rtl.sv
ID_Stage/rtl.sv
ALU/rtl.sv
ALU_Control/rtl.sv
EX_Stage/rtl.sv
WB_Stage/rtl.sv
Single_Cycle_RISCV/rtl.sv
tests/
rnr-stage.yaml
```

## Simulation

Install Icarus Verilog with SystemVerilog support. Run commands from the repository root:

```sh
iverilog -g2012 -s tb_if_stage -o /tmp/tb_if \
  IF_Stage/rtl.sv tests/tb_if_stage.sv
vvp /tmp/tb_if

iverilog -g2012 -s tb_register_file -o /tmp/tb_rf \
  Register_File/rtl.sv tests/tb_register_file.sv
vvp /tmp/tb_rf

iverilog -g2012 -s tb_alu -o /tmp/tb_alu \
  ALU/rtl.sv tests/tb_alu.sv
vvp /tmp/tb_alu

iverilog -g2012 -s tb_core_smoke -o /tmp/tb_core \
  IF_Stage/rtl.sv Decoder/rtl.sv Immediate_Generator/rtl.sv \
  Register_File/rtl.sv Main_Control/rtl.sv ID_Stage/rtl.sv \
  ALU/rtl.sv ALU_Control/rtl.sv EX_Stage/rtl.sv \
  WB_Stage/rtl.sv Single_Cycle_RISCV/rtl.sv \
  tests/tb_core_smoke.sv
vvp /tmp/tb_core
```

Decode/control/writeback test:

```sh
iverilog -g2012 -s tb_decode_control_wb -o /tmp/tb_decode \
  Decoder/rtl.sv Immediate_Generator/rtl.sv Main_Control/rtl.sv \
  ALU_Control/rtl.sv WB_Stage/rtl.sv tests/tb_decode_control_wb.sv
vvp /tmp/tb_decode
```

## Synthesis

With Yosys 0.33 installed, a basic hierarchy/synthesis check can be run with:

```sh
yosys -p 'read_verilog -sv IF_Stage/rtl.sv Decoder/rtl.sv Immediate_Generator/rtl.sv Register_File/rtl.sv Main_Control/rtl.sv ID_Stage/rtl.sv ALU/rtl.sv ALU_Control/rtl.sv EX_Stage/rtl.sv WB_Stage/rtl.sv Single_Cycle_RISCV/rtl.sv; hierarchy -check -top single_cycle_riscv; proc; check'
```

The course CI is authoritative for the official module-by-module behavioral checks. The local testbenches in `tests/` are targeted smoke/unit tests, not a replacement for the course's directed/random validation suite.

## CI stage

`rnr-stage.yaml` initially selects `fetch` and lists every required module/source path. Keep it at `fetch` until RISC-n-Roll-CI reports PASS; then advance to `decode`, `execute`, `writeback`, and `integration` in order. Each stage checks itself and all earlier stages.

## Updating your existing GitHub repository

This package is intended to be copied into your existing local clone, not used to create a new repository. Back up or commit your current work first. From your existing repository root, copy these files over the corresponding paths, then:

```sh
git status
git add -A
git commit -m "Complete single-cycle RV32I processor"
git push origin main
```

These commands preserve your existing `.git` directory and commit history. Review `git status` before committing. No push or CI result is claimed by this package.
