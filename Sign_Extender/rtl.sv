module extend(
    input  logic [31:7] instr,
    input  logic [1:0]  immsrc,
    output logic [31:0] immext
);
    always_comb begin
        case (immsrc)
            2'b00: immext = {{20{instr[31]}}, instr[31:20]};
            2'b01: immext = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            // B/J immediates omit their implicit bit zero; datapath shifts left once.
            2'b10: immext = {{20{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8]};
            2'b11: immext = {{12{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21]};
            default: immext = 32'd0;
        endcase
    end
endmodule
