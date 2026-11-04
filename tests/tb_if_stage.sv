`timescale 1ns/1ps
module tb_if_stage;
    logic clk=0, reset=0, stall=0, and_out=0;
    logic [31:0] pc_signed_offset=0, address, pc_new;
    if_stage dut(.*);
    always #5 clk=~clk;
    initial begin
        reset=1; #1;
        if (address !== 32'h80000000) $fatal(1,"async reset failed");
        reset=0; #1;
        if (pc_new !== 32'h80000004) $fatal(1,"pc+4 failed");
        @(negedge clk);
        stall=1;
        @(posedge clk); #1;
        if (address !== 32'h80000000) $fatal(1,"stall did not hold PC");
        @(negedge clk); stall=0; and_out=1; pc_signed_offset=32'h80000040;
        @(posedge clk); #1;
        if (address !== 32'h80000040) $fatal(1,"branch target failed");
        $display("tb_if_stage PASS"); $finish;
    end
endmodule
