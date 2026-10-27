module top(
    input  logic        clk,
    input  logic        reset,
    output logic [31:0] WriteData,
    output logic [31:0] DataAdr,
    output logic        MemWrite
);
    logic [31:0] PC, Instr, ReadData;
    imem imem_inst(.a(PC), .rd(Instr));
    riscvsingle cpu(.clk(clk), .reset(reset), .PC(PC), .Instr(Instr),
                    .MemWrite(MemWrite), .ALUResult(DataAdr),
                    .WriteData(WriteData), .ReadData(ReadData));
    dmem dmem_inst(.clk(clk), .we(MemWrite), .a(DataAdr), .wd(WriteData), .rd(ReadData));
endmodule
