`timescale 1ns/1ps
module tb_alu;
    logic [4:0] alu_control;
    logic [31:0] rs1_data,rs2_data,alu_out;
    logic zero;
    alu dut(.*);
    initial begin
        rs1_data=7; rs2_data=5; alu_control=0; #1;
        if (alu_out!==12 || zero!==0) $fatal(1,"ADD failed");
        alu_control=1; #1;
        if (alu_out!==2) $fatal(1,"SUB failed");
        alu_control=10; #1;
        if (alu_out!==(7^5)) $fatal(1,"XOR failed");
        rs1_data=32'hffffffff; rs2_data=1; alu_control=12; #1;
        if (zero!==1) $fatal(1,"BLT signed failed");
        alu_control=14; #1;
        if (zero!==0) $fatal(1,"BLTU failed");
        rs1_data=9; rs2_data=9; alu_control=10; #1;
        if (zero!==1) $fatal(1,"BEQ failed");
        $display("tb_alu PASS"); $finish;
    end
endmodule
