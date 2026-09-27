// Porta lógica AND de 2 entradas.
// Realiza a operação booleana out = inA & inB.
// Útil como bloco básico para a construção de um acelerador AES.
module porta_and (
    input logic inA, inB,
    output logic out
);

    // Saída é o resultado da operação AND entre as entradas.
    assign out = (inA & inB);

endmodule