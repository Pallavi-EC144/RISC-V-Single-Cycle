`timescale 1ns/1ps
module tb_decode_control_wb;
    logic [31:0] instruction;
    logic [4:0] rs1, rs2, rd;
    logic [6:0] opcode, imm11_5;
    logic [2:0] fn3;
    logic [11:0] imm;
    logic [19:0] imm_uj;
    logic fn7_5;
    logic [31:0] imm_output;
    logic [1:0] memtoreg;
    logic branch, mux_inp, memread, memwrite, alusrc, reg_write;
    logic [2:0] aluop;
    logic [4:0] control_out;
    logic [31:0] mem_out, alu_out, return_addr, pc_signed_offset, wb_data;

    decoder d(.instruction(instruction), .rs1(rs1), .rs2(rs2), .rd(rd),
        .opcode(opcode), .imm11_5(imm11_5), .fn3(fn3), .imm(imm),
        .imm_uj(imm_uj), .fn7_5(fn7_5));
    imm_generator ig(.imm_input(imm), .fn3(fn3), .opcode(opcode),
        .imm_input_uj(imm_uj), .imm_output(imm_output));
    main_control mc(.opcode(opcode), .fn3(fn3), .memtoreg(memtoreg),
        .branch(branch), .mux_inp(mux_inp), .memread(memread),
        .memwrite(memwrite), .alusrc(alusrc), .reg_write(reg_write), .aluop(aluop));
    alu_control ac(.alu_op(aluop), .fn3(fn3), .imm11_5(imm11_5),
        .fn7_5(fn7_5), .control_out(control_out));
    wb_stage wb(.mem_out(mem_out), .alu_out(alu_out), .return_addr(return_addr),
        .imm_out(imm_output), .pc_signed_offset(pc_signed_offset),
        .memtoreg(memtoreg), .opcode_out_d(opcode), .wb_data(wb_data));

    initial begin
        // ADDI x3,x2,-1
        instruction = 32'hfff10193; #1;
        if (opcode !== 7'b0010011 || rd !== 5'd3 || rs1 !== 5'd2 ||
            imm_output !== 32'hffff_ffff || aluop !== 3'b001 ||
            control_out !== 5'b00000 || !reg_write)
            $fatal(1, "ADDI decode/control/immediate failed");

        // BEQ x1,x2,+8
        instruction = 32'h00208463; #1;
        if (opcode !== 7'b1100011 || !branch || imm_output !== 32'd8 ||
            control_out !== 5'b01010)
            $fatal(1, "BEQ decode/control/immediate failed");

        // LUI x4,0x12345
        instruction = 32'h12345237; #1;
        if (imm_output !== 32'h1234_5000 || memtoreg !== 2'b10)
            $fatal(1, "LUI immediate/control failed");
        alu_out=32'h11111111; mem_out=32'h22222222;
        return_addr=32'h33333333; pc_signed_offset=32'h44444444; #1;
        if (wb_data !== 32'h1234_5000) $fatal(1, "LUI writeback failed");

        // JAL x1,+8
        instruction = 32'h008000ef; #1;
        if (imm_output !== 32'd8 || opcode !== 7'b1101111)
            $fatal(1, "JAL immediate failed");
        return_addr=32'h80000004; #1;
        if (wb_data !== 32'h80000004) $fatal(1, "JAL writeback failed");

        $display("tb_decode_control_wb PASS");
        $finish;
    end
endmodule
