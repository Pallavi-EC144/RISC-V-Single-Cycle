module datapath(
    input  logic        clk,
    input  logic        reset,
    input  logic [1:0]  ResultSrc,
    input  logic        PCSrc,
    input  logic        ALUSrc,
    input  logic        RegWrite,
    input  logic [1:0]  ImmSrc,
    input  logic [2:0]  ALUControl,
    output logic        Zero,
    output logic [31:0] PC,
    input  logic [31:0] Instr,
    output logic [31:0] ALUResult,
    output logic [31:0] WriteData,
    input  logic [31:0] ReadData
);
    logic [31:0] PCNext, PCPlus4, PCTarget;
    logic [31:0] PCJumpTarget, PCTargetJALR;
    logic [31:0] ImmExt, SrcA, SrcB, Result, RD1, RD2;

    flopr #(.WIDTH(32)) pc_reg(
        .d(PCNext), .clk(clk), .reset(reset), .q(PC)
    );

    adder pc_plus4(.a(PC), .b(32'd4), .y(PCPlus4));

    extend imm_gen(
        .instr(Instr[31:7]), .immsrc(ImmSrc), .immext(ImmExt)
    );

    adder pc_target(
        .a(PC), .b(ImmExt << 1), .y(PCTarget)
    );

    assign PCTargetJALR = (RD1 + ImmExt) & 32'hFFFFFFFE;

    assign PCJumpTarget =
        (Instr[6:0] == 7'b1100111) ? PCTargetJALR : PCTarget;

    mux2 #(.WIDTH(32)) pc_mux(
        .d0(PCPlus4), .d1(PCJumpTarget), .s(PCSrc), .y(PCNext)
    );

    regfile rf(
        .clk(clk), .we3(RegWrite),
        .a1(Instr[19:15]), .a2(Instr[24:20]), .a3(Instr[11:7]),
        .wd3(Result), .rd1(RD1), .rd2(RD2)
    );

    assign WriteData = RD2;
    assign SrcA = RD1;

    mux2 #(.WIDTH(32)) srcb_mux(
        .d0(RD2), .d1(ImmExt), .s(ALUSrc), .y(SrcB)
    );

    alu alu_unit(
        .a(SrcA), .b(SrcB), .alucontrol(ALUControl), .result(ALUResult)
    );

    assign Zero = (ALUResult == 32'd0);

    mux3 #(.WIDTH(32)) result_mux(
        .d0(ALUResult), .d1(ReadData), .d2(PCPlus4),
        .s(ResultSrc), .y(Result)
    );
endmodule
