module porta_and (
    input logic inA, inB,
    output logic out
);
    
    assign out = (inA & inB);

endmodule