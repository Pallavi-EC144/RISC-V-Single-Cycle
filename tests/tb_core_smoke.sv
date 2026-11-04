`timescale 1ns/1ps
// Basic top-level smoke test. External instruction/data memories are modeled here.
module tb_core_smoke;
    logic clk=0, reset=0, stall=0;
    logic [31:0] instruction=32'h00000013; // ADDI x0,x0,0 (NOP)
    logic [31:0] mem_out=0;
    logic [31:0] rs2_data,alu_out,address;
    logic mem_write,mem_read;
    logic [2:0] fn3;
    logic [6:0] opcode;
    single_cycle_riscv dut(.*);
    always #5 clk=~clk;
    initial begin
        reset=1; #1;
        if (address !== 32'h80000000) $fatal(1,"core PC reset failed");
        reset=0;
        repeat(3) @(posedge clk);
        #1;
        if (address !== 32'h8000000c) $fatal(1,"core sequential PC failed");
        $display("tb_core_smoke PASS"); $finish;
    end
endmodule
