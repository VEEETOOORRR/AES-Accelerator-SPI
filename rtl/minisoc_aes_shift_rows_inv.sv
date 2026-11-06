module minisoc_aes_inv_shift_rows (
    input  logic [127:0] state_in,
    output logic [127:0] state_out
);

    // Mapeamento dos bytes de saída agrupados por coluna (Words 0 a 3)
    assign state_out = {
        // --- Word 0 de saída (bits [127:96]) ---
        state_in[127:120], // r=0, c=0 <- Byte 0  (sem shift)
        state_in[23:16],   // r=1, c=0 <- Byte 13 (shift 1 à direita: veio de c=3)
        state_in[47:40],   // r=2, c=0 <- Byte 10 (shift 2 à direita: veio de c=2)
        state_in[71:64],   // r=3, c=0 <- Byte 7  (shift 3 à direita: veio de c=1)

        // --- Word 1 de saída (bits [95:64]) ---
        state_in[95:88],   // r=0, c=1 <- Byte 4  (sem shift)
        state_in[119:112], // r=1, c=1 <- Byte 1  (shift 1 à direita: veio de c=0)
        state_in[15:8],    // r=2, c=1 <- Byte 14 (shift 2 à direita: veio de c=3)
        state_in[39:32],   // r=3, c=1 <- Byte 11 (shift 3 à direita: veio de c=2)

        // --- Word 2 de saída (bits [63:32]) ---
        state_in[63:56],   // r=0, c=2 <- Byte 8  (sem shift)
        state_in[87:80],   // r=1, c=2 <- Byte 5  (shift 1 à direita: veio de c=1)
        state_in[111:104], // r=2, c=2 <- Byte 2  (shift 2 à direita: veio de c=0)
        state_in[7:0],     // r=3, c=2 <- Byte 15 (shift 3 à direita: veio de c=3)

        // --- Word 3 de saída (bits [31:0]) ---
        state_in[31:24],   // r=0, c=3 <- Byte 12 (sem shift)
        state_in[55:48],   // r=1, c=3 <- Byte 9  (shift 1 à direita: veio de c=2)
        state_in[79:72],   // r=2, c=3 <- Byte 6  (shift 2 à direita: veio de c=1)
        state_in[103:96]   // r=3, c=3 <- Byte 3  (shift 3 à direita: veio de c=0)
    };

endmodule