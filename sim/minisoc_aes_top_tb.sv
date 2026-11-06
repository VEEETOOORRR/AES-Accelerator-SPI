`timescale 1ns / 1ps

module minisoc_aes_top_tb;

    minisoc_aes_sub_bytes_tb  #(.STANDALONE(0)) subBytes_tb();
    minisoc_aes_shift_rows_tb #(.STANDALONE(0)) shiftRows_tb();

    int total_errors;

    initial begin
        subBytes_tb.run_tests();
        shiftRows_tb.run_tests();

        total_errors = subBytes_tb.error_count + shiftRows_tb.error_count;

        $display("================================================================");
        if (total_errors == 0)
            $display("  [TOP] TODOS OS TESTBENCHES PASSARAM");
        else
            $display("  [TOP] FALHA: %0d erro(s) no total", total_errors);
        $display("================================================================");
        $finish;
    end

    initial begin
        $dumpfile("waves.fsdb");
        $dumpvars(0, minisoc_aes_top_tb);
    end


endmodule