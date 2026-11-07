`timescale 1ns / 1ps

module minisoc_aes_shift_rows_tb;

    // Sinais para conectar ao DUT
    logic [127:0] state_in;
    logic [127:0] state_out;

    // Instanciação do DUT
    minisoc_aes_shift_rows dut (
        .op(0),
        .state_in(state_in),
        .state_out(state_out)
    );

    // Modelo de referência da transformação ShiftRows (FIPS 197)
    function automatic [127:0] ref_shift_rows(input logic [127:0] in);
        logic [7:0] in_b [0:15];
        logic [7:0] out_b [0:15];
        logic [127:0] result;
        begin
            // Extrai os 16 bytes de entrada (organizados por coluna)
            for (int i = 0; i < 16; i++) begin
                in_b[i] = in[127 - i*8 -: 8];
            end

            // Linha 0 (r=0): sem deslocamento (shift 0)
            out_b[0]  = in_b[0];   // Col 0
            out_b[4]  = in_b[4];   // Col 1
            out_b[8]  = in_b[8];   // Col 2
            out_b[12] = in_b[12];  // Col 3

            // Linha 1 (r=1): deslocamento circular de 1 byte à esquerda (shift 1)
            out_b[1]  = in_b[5];   // Col 0 recebe Col 1
            out_b[5]  = in_b[9];   // Col 1 recebe Col 2
            out_b[9]  = in_b[13];  // Col 2 recebe Col 3
            out_b[13] = in_b[1];   // Col 3 recebe Col 0

            // Linha 2 (r=2): deslocamento circular de 2 bytes à esquerda (shift 2)
            out_b[2]  = in_b[10];  // Col 0 recebe Col 2
            out_b[6]  = in_b[14];  // Col 1 recebe Col 3
            out_b[10] = in_b[2];   // Col 2 recebe Col 0
            out_b[14] = in_b[6];   // Col 3 recebe Col 1

            // Linha 3 (r=3): deslocamento circular de 3 bytes à esquerda (shift 3)
            out_b[3]  = in_b[15];  // Col 0 recebe Col 3
            out_b[7]  = in_b[3];   // Col 1 recebe Col 0
            out_b[11] = in_b[7];   // Col 2 recebe Col 1
            out_b[15] = in_b[11];  // Col 3 recebe Col 2

            // Reconstrói a palavra de 128 bits
            for (int i = 0; i < 16; i++) begin
                result[127 - i*8 -: 8] = out_b[i];
            end
            return result;
        end
    endfunction

    int error_count;
    int test_count;

    // Task para verificação e exibição de detalhes em caso de falha
    task automatic check_vector(
        input logic [127:0] test_in,
        input logic [127:0] exp_out,
        input string        test_name
    );
        logic mismatch;
        begin
            state_in = test_in;
            #5 // Propagação combinacional
            test_count++;
            mismatch = (state_out !== exp_out);

            if (mismatch) begin
                error_count++;
                $display("[ERRO] Falha no teste '%s':", test_name);
                $display("       Entrada:  0x%032X", test_in);
                $display("       Esperado: 0x%032X", exp_out);
                $display("       Obtido:   0x%032X", state_out);
                for (int b = 0; b < 16; b++) begin
                    if (state_out[127 - b*8 -: 8] !== exp_out[127 - b*8 -: 8]) begin
                        $display("       -> Byte %0d (bits [%0d:%0d]) incorreto: obtido=0x%02X, esperado=0x%02X",
                                 b, 127 - b*8, 120 - b*8,
                                 state_out[127 - b*8 -: 8],
                                 exp_out[127 - b*8 -: 8]);
                    end
                end
            end else begin
                $display("[OK] %s passou.", test_name);
            end
        end
    endtask

    parameter bit STANDALONE = 1'b1;

    task automatic run_tests();

        error_count = 0;
        test_count  = 0;

        $display("================================================================");
        $display("[INFO] Iniciando Testbench: minisoc_aes_shift_rows_tb");
        $display("[INFO] Testando vetores FIPS-197, casos isolados e aleatorios");
        $display("================================================================");

        // Caso 1: NIST FIPS 197 Apêndice B (ShiftRows da Rodada 1)
        check_vector(
            128'hd4_27_11_ae_e0_bf_98_f1_b8_b4_5d_e5_1e_41_8a_84,
            128'hd4_bf_5d_84_e0_b4_8a_ae_b8_41_11_f1_1e_27_98_e5,
            "FIPS-197 Apendice B (Rodada 1 ShiftRows)"
        );

        // Caso 2: NIST FIPS 197 Apêndice C.1 (ShiftRows da Rodada 2)
        check_vector(
            128'h49_92_84_89_45_db_96_f1_7f_39_87_1a_77_02_53_3b,
            128'h49_db_87_3b_45_39_53_89_7f_02_84_f1_77_92_96_1a,
            "FIPS-197 Apendice C.1 (Rodada 2 ShiftRows)"
        );

        // Caso 3: Matriz com bytes sequenciais 0x00 a 0x0F
        check_vector(
            128'h00010203_04050607_08090a0b_0c0d0e0f,
            128'h00050a0f_04090e03_080d0207_0c01060b,
            "Bytes sequenciais 0x00 a 0x0F"
        );

        // Caso 4: Matriz homogênea (todos os bytes 0x00)
        check_vector(
            128'h00000000_00000000_00000000_00000000,
            128'h00000000_00000000_00000000_00000000,
            "Todos os bytes 0x00"
        );

        // Caso 5: Matriz homogênea (todos os bytes 0xFF)
        check_vector(
            128'hffffffff_ffffffff_ffffffff_ffffffff,
            128'hffffffff_ffffffff_ffffffff_ffffffff,
            "Todos os bytes 0xFF"
        );

        // Caso 6: Matriz homogênea (todos os bytes 0x55)
        check_vector(
            128'h55555555_55555555_55555555_55555555,
            128'h55555555_55555555_55555555_55555555,
            "Todos os bytes 0x55"
        );

        // Caso 7: Isolamento da Linha 0 (deve manter posições - shift 0)
        check_vector(
            128'haa000000_bb000000_cc000000_dd000000,
            128'haa000000_bb000000_cc000000_dd000000,
            "Isolamento da Linha 0 (sem shift)"
        );

        // Caso 8: Isolamento da Linha 1 (shift 1 a esquerda)
        check_vector(
            128'h00aa0000_00bb0000_00cc0000_00dd0000,
            128'h00bb0000_00cc0000_00dd0000_00aa0000,
            "Isolamento da Linha 1 (shift 1)"
        );

        // Caso 9: Isolamento da Linha 2 (shift 2 a esquerda)
        check_vector(
            128'h0000aa00_0000bb00_0000cc00_0000dd00,
            128'h0000cc00_0000dd00_0000aa00_0000bb00,
            "Isolamento da Linha 2 (shift 2)"
        );

        // Caso 10: Isolamento da Linha 3 (shift 3 a esquerda)
        check_vector(
            128'h000000aa_000000bb_000000cc_000000dd,
            128'h000000dd_000000aa_000000bb_000000cc,
            "Isolamento da Linha 3 (shift 3)"
        );

        // Testes Aleatórios contra Modelo de Referência
        $display("[INFO] Executando 100 testes com vetores pseudo-aleatorios...");
        for (int r = 0; r < 100; r++) begin
            logic [127:0] rand_in;
            logic [127:0] exp_out;

            rand_in = { $urandom(), $urandom(), $urandom(), $urandom() };
            exp_out = ref_shift_rows(rand_in);

            state_in = rand_in;
            #5
            test_count++;
            if (state_out !== exp_out) begin
                error_count++;
                $display("[ERRO] Falha no teste aleatorio #%0d!", r + 1);
                $display("       Entrada:  0x%032X", rand_in);
                $display("       Esperado: 0x%032X", exp_out);
                $display("       Obtido:   0x%032X", state_out);
            end
        end

        $display("----------------------------------------------------------------");
        $display("[RESUMO] Total de testes executados: %0d", test_count);
        $display("[RESUMO] Testes com sucesso:        %0d", test_count - error_count);
        $display("[RESUMO] Testes com falha:          %0d", error_count);
        $display("----------------------------------------------------------------");

        if (error_count == 0) begin
            $display("================================================================");
            $display("              >>> STATUS FINAL: PASS <<<                       ");
            $display(" Todos os testes de minisoc_aes_shift_rows passaram com sucesso!");
            $display("================================================================");
        end else begin
            $display("================================================================");
            $display("              >>> STATUS FINAL: FAIL <<<                       ");
            $display(" minisoc_aes_shift_rows falhou! Total de erros: %0d", error_count);
            $display("================================================================");
        end

    
    endtask

    initial if (STANDALONE) begin
        run_tests();
        $finish;
    end

endmodule
