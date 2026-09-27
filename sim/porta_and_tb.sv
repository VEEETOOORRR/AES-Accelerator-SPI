`timescale 1ns/1ps

module porta_and_tb;

    logic inA, inB, out;

    porta_and a (
        .inA(inA),
        .inB(inB),
        .out(out)
    );


    initial begin
        inA = 0;
        inB = 0;

        #5

        inA = 1;
        inB = 0;

        #5

        inA = 0;
        inB = 1;

        #5

        inA = 1;
        inB = 1;

        #5

        $finish;

    end

    initial begin
        $dumpfile("waves.fsdb");
        $dumpvars(0, porta_and_tb);
    end

endmodule