# Relatório Semanal - w02

Meta semanal inicial: Definir arquitetura do projeto.

Nova meta semanal: Implementar módulos combinacionais de SubBytes e ShiftRows e seus testbenches.

## Principais dúvidas arquiteturais:

### SPI:

Semana passada elenquei as seguintes dúvidas a respeito do funcionamento do circuito, porém todas foram sanadas pelo Block Guide:

Entendo que o dispositivo SPI do projeto funcionará como um slave. Ele deve dar suporte aos 4 modos diferentes do SPI, referentes à polaridade e fase do clock? Caso positivo, como isso será configurado em tempo de execução? É mexendo em algum jumper/ ligando determinado pino a outro? 

**Resposta: O módulo SPI vai funcionar no modo 0.**

Considera-se que o algoritmo AES criptografa/descriptografa 128 bits de informação de cada vez. O módulo SPI deve receber 128 bits de informação e logo em seguida retornar os 128 bits criptografados? Ou ele recebe e envia blocos maiores de cada vez? É o caso de implementar o suporte a configurar um "tamanho padrão" variável? Por ex: 128 bits, 256b, 1Kb, 2Kb, 1Mb... 

**Resposta: O AES vai criptografar/descriptografar o que estiver na memória compartilhada, que por sua vez armazena até 1024 palavras de 32 bits.**

SPI é um protocolo serial e o mesmo barramento que envia o plaintext envia também a chave. Como diferenciar os dois? Sugiro desenvolver um sistema de "comandos" hexadecimais, onde é enviado um comando e logo em seguida uma informação referente a esse comando. 

**Resposta: O SPI servirá apenas para configuração e controle. O plaintext é diretamente enviado a uma memória compartilhada entre o usuário e o módulo AES.**

### Datapath do AES:

Para a parte de substituição pela tabela, instancia-se 16 LUTs separadas para substituir os 16 bytes em um ciclo de clock, ou gasta-se 16 ciclos para substituir cada byte de cada vez? A primeira opção gera ganho de velocidade em detrimento de área, enquanto a segunda otimiza a área em detrimento da velocidade. 

**Resposta: Instancia-se 16 LUTs separadas e a substituição é realizada de maneira combinacional.**

São necessários datapaths diferentes para criptografar e descriptografar uma informação? Visto que na descriptografia são utilizadas as transformações inversas de SubBytes, ShiftRows e MixColumns. 

**Resposta: O Block Guide deixa subentendido que seria o mesmo datapath para ambas as operações, diferenciadas por um bit no registrador AES_CONTROL.**

## Entregáveis da semana feitos:

### AES-Sbox

Criado módulo minisoc_aes_sbox contendo LUT de uma tabela de substituição.

### AES-SubBytes

Criado módulo minisoc_aes_sub_bytes responsável por substituir os 16 bytes do estado de entrada combinacionalmente. São instanciados 16 módulos *minisoc_aes_sbox* mapeados para cada byte.

### AES-ShiftRows

Módulo responsável por shiftar linhas. Inicialmente implementei utilizando vetores [3:0][3:0][7:0] para representar a matriz de estado. Tal notação facilitaria a implementação da operação de shift, mas ao ler minuciosamente o Block Guide disponibilizado e a descrição da divisão de palavras de 32 bits dentro da memória, decidi por representar as matrizes como um vetor [127:0].

## Testbenches:

Foram criados três arquivos de testbench. o Módulo minisoc_aes_top_tb instancia os outros dois e gera um resumo de erros detectados pelos testbenches. 

### AES-SubBytes

minisoc_aes_sub_bytes_tb verifica os módulos minisoc_aes_sub_bytes e, consequentemente, minisoc_aes_sbox. Realiza os seguintes casos de teste:

- Vetor FIPS-197 Apêndice B (Rodada 1)
- Vetor FIPS-197 Apêndice C.1 (Rodada 2)
- Vetor FIPS-197 Apêndice C.1 (Rodada 3)
- Todos os bytes 0x00 (saída 0x63)
- Todos os bytes 0xFF (saída 0x16)
- Todos os bytes 0x52 (saída nula)
- Bytes sequenciais 0x00 a 0x0F
- Bytes sequenciais 0x10 a 0x1F
- Padrão homogêneo 0xA5
- 100 vetores pseudo-aleatórios


### AES-ShiftRows

minisoc_aes_shift_rows_tb verifica o módulo minisoc_aes_shift_rows. Realiza os seguintes casos de teste:

Vetor FIPS-197 Apêndice B (Rodada 1)
Vetor FIPS-197 Apêndice C.1 (Rodada 2)
Bytes sequenciais 0x00 a 0x0F
Todos os bytes 0x00
Todos os bytes 0xFF
Todos os bytes 0x55
Isolamento da linha 0 (sem deslocamento)
Isolamento da linha 1 (deslocamento de 1 byte)
Isolamento da linha 2 (deslocamento de 2 bytes)
Isolamento da linha 3 (deslocamento de 3 bytes)
100 vetores pseudo-aleatórios comparados com o modelo de referência

**Saída do Testbench:**

    ================================================================
    [INFO] Iniciando Testbench: minisoc_aes_sub_bytes_tb
    [INFO] Testando vetores padroes FIPS-197, casos limite e aleatorios
    ================================================================
    [OK] FIPS-197 Apendice B (Rodada 1) passou.
    [OK] FIPS-197 Apendice C.1 (Rodada 2) passou.
    [OK] FIPS-197 Apendice C.1 (Rodada 3) passou.
    [OK] Todos os bytes 0x00 passou.
    [OK] Todos os bytes 0xFF passou.
    [OK] Todos os bytes 0x52 -> Saida nula passou.
    [OK] Bytes sequenciais 0x00 a 0x0F passou.
    [OK] Bytes sequenciais 0x10 a 0x1F passou.
    [OK] Padrao homogeneo 0xA5 passou.
    [INFO] Executando 100 testes com vetores pseudo-aleatorios...
    ----------------------------------------------------------------
    [RESUMO] Total de testes executados: 109
    [RESUMO] Testes com sucesso:        109
    [RESUMO] Testes com falha:          0
    ----------------------------------------------------------------
    ================================================================
                >>> STATUS FINAL: PASS <<<                       
    Todos os testes de minisoc_aes_sub_bytes passaram com sucesso!
    ================================================================
    ================================================================
    [INFO] Iniciando Testbench: minisoc_aes_shift_rows_tb
    [INFO] Testando vetores FIPS-197, casos isolados e aleatorios
    ================================================================
    [OK] FIPS-197 Apendice B (Rodada 1 ShiftRows) passou.
    [OK] FIPS-197 Apendice C.1 (Rodada 2 ShiftRows) passou.
    [OK] Bytes sequenciais 0x00 a 0x0F passou.
    [OK] Todos os bytes 0x00 passou.
    [OK] Todos os bytes 0xFF passou.
    [OK] Todos os bytes 0x55 passou.
    [OK] Isolamento da Linha 0 (sem shift) passou.
    [OK] Isolamento da Linha 1 (shift 1) passou.
    [OK] Isolamento da Linha 2 (shift 2) passou.
    [OK] Isolamento da Linha 3 (shift 3) passou.
    [INFO] Executando 100 testes com vetores pseudo-aleatorios...
    ----------------------------------------------------------------
    [RESUMO] Total de testes executados: 110
    [RESUMO] Testes com sucesso:        110
    [RESUMO] Testes com falha:          0
    ----------------------------------------------------------------
    ================================================================
                >>> STATUS FINAL: PASS <<<                       
    Todos os testes de minisoc_aes_shift_rows passaram com sucesso!
    ================================================================
    ================================================================
    [TOP] TODOS OS TESTBENCHES PASSARAM
    ================================================================