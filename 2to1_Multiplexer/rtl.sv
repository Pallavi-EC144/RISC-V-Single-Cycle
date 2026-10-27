module mux2 #(parameter WIDTH = 8)(
    input  logic [WIDTH-1:0] d0,
    input  logic [WIDTH-1:0] d1,
    input  logic             s,
    output logic [WIDTH-1:0] y
);
    always_comb begin
        if (s)
            y = d1;
        else
            y = d0;
    end
endmodule
