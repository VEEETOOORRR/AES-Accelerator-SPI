`timescale 1ns / 1ps

module minisoc_aes_sub_bytes_tb;

    // Sinais para conectar ao DUT
    logic [127:0] state_matrix_in;
    logic [127:0] state_matrix_out;

    // Instanciação do DUT
    minisoc_aes_sub_bytes dut (
        .state_matrix_in (state_matrix_in),
        .state_matrix_out(state_matrix_out)
    );

    // Tabela de referência da S-box do AES (FIPS 197)
    const logic [7:0] sbox_expected [0:255] = '{
        // 0x00 - 0x0F
        8'h63, 8'h7C, 8'h77, 8'h7B, 8'hF2, 8'h6B, 8'h6F, 8'hC5, 8'h30, 8'h01, 8'h67, 8'h2B, 8'hFE, 8'hD7, 8'hAB, 8'h76,
        // 0x10 - 0x1F
        8'hCA, 8'h82, 8'hC9, 8'h7D, 8'hFA, 8'h59, 8'h47, 8'hF0, 8'hAD, 8'hD4, 8'hA2, 8'hAF, 8'h9C, 8'hA4, 8'h72, 8'hC0,
        // 0x20 - 0x2F
        8'hB7, 8'hFD, 8'h93, 8'h26, 8'h36, 8'h3F, 8'hF7, 8'hCC, 8'h34, 8'hA5, 8'hE5, 8'hF1, 8'h71, 8'hD8, 8'h31, 8'h15,
        // 0x30 - 0x3F
        8'h04, 8'hC7, 8'h23, 8'hC3, 8'h18, 8'h96, 8'h05, 8'h9A, 8'h07, 8'h12, 8'h80, 8'hE2, 8'hEB, 8'h27, 8'hB2, 8'h75,
        // 0x40 - 0x4F
        8'h09, 8'h83, 8'h2C, 8'h1A, 8'h1B, 8'h6E, 8'h5A, 8'hA0, 8'h52, 8'h3B, 8'hD6, 8'hB3, 8'h29, 8'hE3, 8'h2F, 8'h84,
        // 0x50 - 0x5F
        8'h53, 8'hD1, 8'h00, 8'hED, 8'h20, 8'hFC, 8'hB1, 8'h5B, 8'h6A, 8'hCB, 8'hBE, 8'h39, 8'h4A, 8'h4C, 8'h58, 8'hCF,
        // 0x60 - 0x6F
        8'hD0, 8'hEF, 8'hAA, 8'hFB, 8'h43, 8'h4D, 8'h33, 8'h85, 8'h45, 8'hF9, 8'h02, 8'h7F, 8'h50, 8'h3C, 8'h9F, 8'hA8,
        // 0x70 - 0x7F
        8'h51, 8'hA3, 8'h40, 8'h8F, 8'h92, 8'h9D, 8'h38, 8'hF5, 8'hBC, 8'hB6, 8'hDA, 8'h21, 8'h10, 8'hFF, 8'hF3, 8'hD2,
        // 0x80 - 0x8F
        8'hCD, 8'h0C, 8'h13, 8'hEC, 8'h5F, 8'h97, 8'h44, 8'h17, 8'hC4, 8'hA7, 8'h7E, 8'h3D, 8'h64, 8'h5D, 8'h19, 8'h73,
        // 0x90 - 0x9F
        8'h60, 8'h81, 8'h4F, 8'hDC, 8'h22, 8'h2A, 8'h90, 8'h88, 8'h46, 8'hEE, 8'hB8, 8'h14, 8'hDE, 8'h5E, 8'h0B, 8'hDB,
        // 0xA0 - 0xAF
        8'hE0, 8'h32, 8'h3A, 8'h0A, 8'h49, 8'h06, 8'h24, 8'h5C, 8'hC2, 8'hD3, 8'hAC, 8'h62, 8'h91, 8'h95, 8'hE4, 8'h79,
        // 0xB0 - 0xBF
        8'hE7, 8'hC8, 8'h37, 8'h6D, 8'h8D, 8'hD5, 8'h4E, 8'hA9, 8'h6C, 8'h56, 8'hF4, 8'hEA, 8'h65, 8'h7A, 8'hAE, 8'h08,
        // 0xC0 - 0xCF
        8'hBA, 8'h78, 8'h25, 8'h2E, 8'h1C, 8'hA6, 8'hB4, 8'hC6, 8'hE8, 8'hDD, 8'h74, 8'h1F, 8'h4B, 8'hBD, 8'h8B, 8'h8A,
        // 0xD0 - 0xDF
        8'h70, 8'h3E, 8'hB5, 8'h66, 8'h48, 8'h03, 8'hF6, 8'h0E, 8'h61, 8'h35, 8'h57, 8'hB9, 8'h86, 8'hC1, 8'h1D, 8'h9E,
        // 0xE0 - 0xEF
        8'hE1, 8'hF8, 8'h98, 8'h11, 8'h69, 8'hD9, 8'h8E, 8'h94, 8'h9B, 8'h1E, 8'h87, 8'hE9, 8'hCE, 8'h55, 8'h28, 8'hDF,
        // 0xF0 - 0xFF
        8'h8C, 8'hA1, 8'h89, 8'h0D, 8'hBF, 8'hE6, 8'h42, 8'h68, 8'h41, 8'h99, 8'h2D, 8'h0F, 8'hB0, 8'h54, 8'hBB, 8'h16
    };

    // Modelo de referência para a operação SubBytes em 128 bits
    function automatic [127:0] sub_bytes_ref(input logic [127:0] state_in);
        logic [127:0] state_out;
        logic [7:0]   byte_val;
        begin
            for (int b = 0; b < 16; b++) begin
                byte_val = state_in[127 - b*8 -: 8];
                state_out[127 - b*8 -: 8] = sbox_expected[byte_val];
            end
            return state_out;
        end
    endfunction

    int error_count;
    int test_count;

    // Task auxiliar para verificação e exibição de erros detalhados
    task automatic check_vector(
        input logic [127:0] test_in,
        input logic [127:0] exp_out,
        input string        test_name
    );
        logic mismatch;
        begin
            state_matrix_in = test_in;
            #5 // Aguarda propagação combinacional
            test_count++;
            mismatch = (state_matrix_out !== exp_out);

            if (mismatch) begin
                error_count++;
                $display("[ERRO] Falha no teste '%s':", test_name);
                $display("       Entrada:  0x%032X", test_in);
                $display("       Esperado: 0x%032X", exp_out);
                $display("       Obtido:   0x%032X", state_matrix_out);
                for (int b = 0; b < 16; b++) begin
                    if (state_matrix_out[127 - b*8 -: 8] !== exp_out[127 - b*8 -: 8]) begin
                        $display("       -> Byte %0d (bits [%0d:%0d]) incorreto: obtido=0x%02X, esperado=0x%02X (in=0x%02X)",
                                 b, 127 - b*8, 120 - b*8,
                                 state_matrix_out[127 - b*8 -: 8],
                                 exp_out[127 - b*8 -: 8],
                                 test_in[127 - b*8 -: 8]);
                    end
                end
            end else begin
                $display("[OK] %s passou.", test_name);
            end
        end
    endtask

    initial begin

        error_count = 0;
        test_count  = 0;

        $display("================================================================");
        $display("[INFO] Iniciando Testbench: minisoc_aes_sub_bytes_tb");
        $display("[INFO] Testando vetores padroes FIPS-197, casos limite e aleatorios");
        $display("================================================================");

        // Caso 1: NIST FIPS 197 Apêndice B (Início da Rodada 1)
        check_vector(
            128'h19_3d_e3_be_a0_f4_e2_2b_9a_c6_8d_2a_e9_f8_cf_4f,
            128'hd4_27_11_ae_e0_bf_98_f1_b8_b4_5d_e5_1e_41_8a_84,
            "FIPS-197 Apendice B (Rodada 1)"
        );

        // Caso 2: NIST FIPS 197 Apêndice C.1 (Rodada 2)
        check_vector(
            128'ha4_74_4f_f2_68_9f_35_2b_6b_5b_ea_43_02_6a_50_49,
            128'h49_92_84_89_45_db_96_f1_7f_39_87_1a_77_02_53_3b,
            "FIPS-197 Apendice C.1 (Rodada 2)"
        );

        // Caso 3: NIST FIPS 197 Apêndice C.1 (Rodada 3)
        check_vector(
            128'h5c_9a_37_72_5b_5d_5a_64_e4_9b_2f_76_08_80_2a_fc,
            128'h4a_b8_9a_40_39_4c_be_43_69_14_15_38_30_cd_e5_b0,
            "FIPS-197 Apendice C.1 (Rodada 3)"
        );

        // Caso 4: Todos os bytes nulos (0x00 -> Sbox: 0x63)
        check_vector(
            128'h00000000_00000000_00000000_00000000,
            128'h63636363_63636363_63636363_63636363,
            "Todos os bytes 0x00"
        );

        // Caso 5: Todos os bytes em 0xFF (0xFF -> Sbox: 0x16)
        check_vector(
            128'hffffffff_ffffffff_ffffffff_ffffffff,
            128'h16161616_16161616_16161616_16161616,
            "Todos os bytes 0xFF"
        );

        // Caso 6: Todos os bytes em 0x52 (0x52 -> Sbox: 0x00)
        check_vector(
            128'h52525252_52525252_52525252_52525252,
            128'h00000000_00000000_00000000_00000000,
            "Todos os bytes 0x52 -> Saida nula"
        );

        // Caso 7: Sequência incremental de bytes 0x00 a 0x0F
        check_vector(
            128'h00010203_04050607_08090a0b_0c0d0e0f,
            128'h637c777b_f26b6fc5_3001672b_fed7ab76,
            "Bytes sequenciais 0x00 a 0x0F"
        );

        // Caso 8: Sequência incremental de bytes 0x10 a 0x1F
        check_vector(
            128'h10111213_14151617_18191a1b_1c1d1e1f,
            128'hca82c97d_fa5947f0_add4a2af_9ca472c0,
            "Bytes sequenciais 0x10 a 0x1F"
        );

        // Caso 9: Padrão alternado 0xA5 (0xA5 -> Sbox: 0x06)
        check_vector(
            128'ha5a5a5a5_a5a5a5a5_a5a5a5a5_a5a5a5a5,
            128'h06060606_06060606_06060606_06060606,
            "Padrao homogeneo 0xA5"
        );

        // Testes Aleatórios contra Modelo de Referência
        $display("[INFO] Executando 100 testes com vetores pseudo-aleatorios...");
        for (int r = 0; r < 100; r++) begin
            logic [127:0] rand_in;
            logic [127:0] exp_out;
            string name;

            rand_in = { $urandom(), $urandom(), $urandom(), $urandom() };
            exp_out = sub_bytes_ref(rand_in);
            $sformat(name, "Vetor aleatorio #%0d", r + 1);

            state_matrix_in = rand_in;
            #5
            test_count++;
            if (state_matrix_out !== exp_out) begin
                error_count++;
                $display("[ERRO] Falha no teste aleatorio #%0d!", r + 1);
                $display("       Entrada:  0x%032X", rand_in);
                $display("       Esperado: 0x%032X", exp_out);
                $display("       Obtido:   0x%032X", state_matrix_out);
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
            $display("  Todos os testes de minisoc_aes_sub_bytes passaram com sucesso!");
            $display("================================================================");
        end else begin
            $display("================================================================");
            $display("              >>> STATUS FINAL: FAIL <<<                       ");
            $display("  minisoc_aes_sub_bytes falhou! Total de erros: %0d", error_count);
            $display("================================================================");
        end

        $finish;
    end

endmodule
