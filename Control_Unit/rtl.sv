module controller(
    input  logic [6:0]  op,
    input  logic [2:0]  funct3,
    input  logic        funct7b5,
    input  logic        Zero,
    output logic [1:0]  ResultSrc,
    output logic        MemWrite,
    output logic        PCSrc,
    output logic        ALUSrc,
    output logic        RegWrite,
    output logic        Jump,
    output logic [1:0]  ImmSrc,
    output logic [2:0]  ALUControl
);
    logic Branch;
    logic [1:0] ALUOp;
    logic BranchTaken;

    maindec md(
        .op(op), .ResultSrc(ResultSrc), .MemWrite(MemWrite),
        .Branch(Branch), .ALUSrc(ALUSrc), .RegWrite(RegWrite),
        .Jump(Jump), .ImmSrc(ImmSrc), .ALUOp(ALUOp)
    );

    aludec ad(
        .opb5(op[5]), .funct3(funct3), .funct7b5(funct7b5),
        .ALUOp(ALUOp), .ALUControl(ALUControl)
    );

    always_comb begin
        BranchTaken = 1'b0;
        if (Branch) begin
            case (funct3)
                3'b000: BranchTaken = Zero;      // BEQ
                3'b001: BranchTaken = ~Zero;     // BNE
                default: BranchTaken = 1'b0;
            endcase
        end
        PCSrc = Jump | BranchTaken;
    end
endmodule
