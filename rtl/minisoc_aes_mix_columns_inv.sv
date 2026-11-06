module minisoc_aes_inv_mix_columns (
    input  logic [127:0] state_in,
    output logic [127:0] state_out
);

    // Função para multiplicação por 0x02 no corpo GF(2^8)
    function automatic logic [7:0] xtime(input logic [7:0] b);
        return (b[7]) ? ((b << 1) ^ 8'h1b) : (b << 1);
    endfunction

    // Multiplicações por constantes da matriz inversa, construídas a partir de xtime
    function automatic logic [7:0] mul9(input logic [7:0] b);
        return xtime(xtime(xtime(b))) ^ b;                         // 8 + 1
    endfunction

    function automatic logic [7:0] mul11(input logic [7:0] b);
        return xtime(xtime(xtime(b))) ^ xtime(b) ^ b;              // 8 + 2 + 1
    endfunction

    function automatic logic [7:0] mul13(input logic [7:0] b);
        return xtime(xtime(xtime(b))) ^ xtime(xtime(b)) ^ b;       // 8 + 4 + 1
    endfunction

    function automatic logic [7:0] mul14(input logic [7:0] b);
        return xtime(xtime(xtime(b))) ^ xtime(xtime(b)) ^ xtime(b); // 8 + 4 + 2
    endfunction

    // Transforma 1 coluna de 4 bytes (32 bits)
    function automatic logic [31:0] inv_mix_single_column(input logic [31:0] col_in);
        logic [7:0] s0, s1, s2, s3;
        logic [7:0] s0_out, s1_out, s2_out, s3_out;

        s0 = col_in[31:24];
        s1 = col_in[23:16];
        s2 = col_in[15:8];
        s3 = col_in[7:0];

        // Multiplicação matricial inversa em GF(2^8)
        s0_out = mul14(s0) ^ mul11(s1) ^ mul13(s2) ^ mul9(s3);   // 14*s0 + 11*s1 + 13*s2 + 9*s3
        s1_out = mul9(s0)  ^ mul14(s1) ^ mul11(s2) ^ mul13(s3);  // 9*s0  + 14*s1 + 11*s2 + 13*s3
        s2_out = mul13(s0) ^ mul9(s1)  ^ mul14(s2) ^ mul11(s3);  // 13*s0 + 9*s1  + 14*s2 + 11*s3
        s3_out = mul11(s0) ^ mul13(s1) ^ mul9(s2)  ^ mul14(s3);  // 11*s0 + 13*s1 + 9*s2  + 14*s3

        return {s0_out, s1_out, s2_out, s3_out};
    endfunction

    // Aplicação paralela simultânea nas 4 colunas (Words 0 a 3)
    assign state_matrix_out[127:96] = inv_mix_single_column(state_matrix_in[127:96]); // Coluna 0
    assign state_matrix_out[95:64]  = inv_mix_single_column(state_matrix_in[95:64]);  // Coluna 1
    assign state_matrix_out[63:32]  = inv_mix_single_column(state_matrix_in[63:32]);  // Coluna 2
    assign state_matrix_out[31:0]   = inv_mix_single_column(state_matrix_in[31:0]);   // Coluna 3

endmodule