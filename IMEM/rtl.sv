module imem(
    input  logic [31:0] a,
    output logic [31:0] rd
);
    logic [31:0] RAM [0:63];

    // The memory image is supplied alongside this module.
    initial begin
        $readmemh("IMEM/memfile.txt", RAM);
    end

    // Byte-addressed CPU address: each word occupies four bytes.
    always_comb begin
        rd = RAM[a[7:2]];
    end
endmodule
