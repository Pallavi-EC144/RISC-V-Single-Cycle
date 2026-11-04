`timescale 1ns/1ps
module tb_register_file;
    logic [4:0] rs1_sel=0,rs2_sel=0,rd_sel=0;
    logic reg_write=0,clk=0,reset=0;
    logic [31:0] wb_data=0,rs1_data,rs2_data;
    register_file dut(.*);
    always #5 clk=~clk;
    initial begin
        reset=1; #1;
        if (rs1_data !== 0 || rs2_data !== 0) $fatal(1,"x0 reset/read failed");
        reset=0; rd_sel=5'd5; wb_data=32'h12345678; reg_write=1;
        @(posedge clk); #1;
        rs1_sel=5'd5; #1;
        if (rs1_data !== 32'h12345678) $fatal(1,"write/read failed");
        rd_sel=0; wb_data=32'hffffffff;
        @(posedge clk); #1;
        rs1_sel=0; #1;
        if (rs1_data !== 0) $fatal(1,"x0 was modified");
        reset=1; #1; rs1_sel=5; #1;
        if (rs1_data !== 0) $fatal(1,"async clear failed");
        $display("tb_register_file PASS"); $finish;
    end
endmodule
