module minisoc_aes_sub_bytes (

    input logic [127:0] state_matrix_in,
    output logic [127:0] state_matrix_out

);

    genvar i;
    generate
        for (i = 0; i < 16; i++) begin : gen_sbox_inv // Instancia uma sbox para cada posição do estado.
            minisoc_aes_sbox_inv sbox_inv (
                .data_in (state_matrix_in[127 - i * 8 : 120 - i * 8]),
                .data_out(state_matrix_out[127 - i * 8 : 120 - i * 8])
            );
        end
    endgenerate

endmodule