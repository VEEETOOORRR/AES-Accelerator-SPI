module minisoc_aes_mix_columns (
    input  logic [127:0] state_in,
    output logic [127:0] state_out
);

    // Função para multiplicação por 0x02 no corpo GF(2^8)
    function automatic logic [7:0] xtime(input logic [7:0] b);
        return (b[7]) ? ((b << 1) ^ 8'h1b) : (b << 1);
    endfunction

    // Transforma 1 coluna de 4 bytes (32 bits)
    function automatic logic [31:0] mix_single_column(input logic [31:0] col_in);
        logic [7:0] s0, s1, s2, s3;
        logic [7:0] s0_out, s1_out, s2_out, s3_out;

        s0 = col_in[31:24];
        s1 = col_in[23:16];
        s2 = col_in[15:8];
        s3 = col_in[7:0];

        // Multiplicação matricial em GF(2^8)
        s0_out = xtime(s0) ^ (xtime(s1) ^ s1) ^ s2 ^ s3;        
        s1_out = s0 ^ xtime(s1) ^ (xtime(s2) ^ s2) ^ s3;         // 1*s0 + 2*s1 + 3*s2 + 1*s3
        s2_out = s0 ^ s1 ^ xtime(s2) ^ (xtime(s3) ^ s3);         // 1*s0 + 1*s1 + 2*s2 + 3*s3
        s3_out = (xtime(s0) ^ s0) ^ s1 ^ s2 ^ xtime(s3);         // 3*s0 + 1*s1 + 1*s2 + 2*s3

        return {s0_out, s1_out, s2_out, s3_out};
    endfunction

    // Aplicação paralela simultânea nas 4 colunas (Words 0 a 3)
    assign state_matrix_out[127:96] = mix_single_column(state_matrix_in[127:96]); // Coluna 0
    assign state_matrix_out[95:64]  = mix_single_column(state_matrix_in[95:64]);  // Coluna 1
    assign state_matrix_out[63:32]  = mix_single_column(state_matrix_in[63:32]);  // Coluna 2
    assign state_matrix_out[31:0]   = mix_single_column(state_matrix_in[31:0]);   // Coluna 3

endmodule