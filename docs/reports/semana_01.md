# Relatório semanal

Para o cumprimento das metas da semana, foi feito o seguinte:

- Adicionados makefile e scripts de síntese adaptados do projeto [Vending Machine](https://github.com/VEEETOOORRR/VendingMachine).
- Criados arquivos `porta_and.sv` e `porta_and_tb.sv` para verificar funcionamento dos scripts adaptados.
- Montados resumos do algoritmo AES e do protocolo SPI para melhor ficar ciente do que se tratam.

## Relatório de estudos

## AES (FIPS 197)

O Advanced Encryption Standard (AES) é um algoritmo de criptografia simétrica de bloco. Ele utiliza a mesma chave secreta para criptografar e descriptografar dados e sempre processa blocos de **128 bits**. O tamanho da chave pode ser de **128, 192 ou 256 bits**, resultando em 10, 12 ou 14 rodadas, respectivamente.

O AES especifica a transformação de um bloco; modos de operação, como CBC ou CTR, definem como aplicar o algoritmo a mensagens maiores. Esses modos não fazem parte das transformações internas descritas nesta seção.

### Tamanho da chave e número de rodadas

| Variante | Tamanho da chave | Número de rodadas |
| :--- | :---: | :---: |
| AES-128 | 128 bits | 10 |
| AES-192 | 192 bits | 12 |
| AES-256 | 256 bits | 14 |

### Operação interna

O AES realiza operações sobre bytes. Cada bloco de 128 bits é organizado em uma matriz de 4 × 4 bytes, chamada **estado** (*State*). Os bytes de entrada são inseridos por coluna: os quatro primeiros bytes formam a primeira coluna, os quatro seguintes formam a segunda, e assim por diante.

Considerando os bytes de entrada denominados B0 a B15, a matriz do estado é organizada da seguinte forma:

|  |  |  |  |
| :---: | :---: | :---: | :---: |
| B0 | B4 | B8 | B12 |
| B1 | B5 | B9 | B13 |
| B2 | B6 | B10 | B14 |
| B3 | B7 | B11 | B15 |

A transformação do estado ocorre por meio de operações aplicadas aos bytes, às linhas ou às colunas. As rodadas utilizam chaves de rodada (*Round Keys*) derivadas da chave original pelo processo de **expansão de chave** (*Key Expansion*).

### Operações fundamentais

| Operação | Descrição |
| :--- | :--- |
| **SubBytes** | Substitui cada byte do estado por outro valor usando uma tabela de substituição não linear chamada **S-box**. |
| **ShiftRows** | Desloca ciclicamente as linhas do estado para a esquerda. A primeira linha não é deslocada; a segunda é deslocada em 1 byte, a terceira em 2 bytes e a quarta em 3 bytes. |
| **MixColumns** | Combina os quatro bytes de cada coluna por meio de uma multiplicação matricial em um corpo finito, GF(2⁸). Cada coluna é processada independentemente. |
| **AddRoundKey** | Combina o estado com a chave da rodada correspondente por meio de uma operação XOR, byte a byte. |

Na operação **MixColumns**, a coluna de entrada é multiplicada pela matriz fixa abaixo, em aritmética de GF(2⁸):

|  |  |  |  |
| :---: | :---: | :---: | :---: |
| 02 | 03 | 01 | 01 |
| 01 | 02 | 03 | 01 |
| 01 | 01 | 02 | 03 |
| 03 | 01 | 01 | 02 |

Os valores dessa matriz são coeficientes hexadecimais. Portanto, essa operação não corresponde a uma multiplicação matricial convencional com números inteiros.

### Etapas da criptografia

Antes da primeira rodada, o estado é combinado com a primeira chave de rodada por meio de **AddRoundKey**. Em seguida, são executadas as rodadas indicadas na tabela:

| Etapa | Operações, na ordem indicada |
| :--- | :--- |
| Adição inicial da chave | AddRoundKey |
| Rodadas 1 até Nr − 1 | SubBytes → ShiftRows → MixColumns → AddRoundKey |
| Rodada final (Nr) | SubBytes → ShiftRows → AddRoundKey |

A última rodada **não executa MixColumns**. O parâmetro **Nr** representa o número total de rodadas: 10 para AES-128, 12 para AES-192 e 14 para AES-256.

### Descriptografia

A descriptografia recupera o texto original a partir do bloco criptografado e da mesma chave secreta. Para isso, utiliza as transformações inversas de SubBytes, ShiftRows e MixColumns. A operação AddRoundKey continua sendo XOR, pois XOR é sua própria inversa.

O fluxo da transformação inversa especificada pelo AES é:

1. **AddRoundKey**, utilizando a última chave de rodada.
2. Para as rodadas de Nr − 1 até 1: **InvShiftRows → InvSubBytes → AddRoundKey → InvMixColumns**.
3. Na rodada final: **InvShiftRows → InvSubBytes → AddRoundKey**, utilizando a chave de rodada inicial. Essa etapa não executa InvMixColumns.

| Operação inversa | Descrição |
| :--- | :--- |
| **InvSubBytes** | Aplica a S-box inversa a cada byte do estado. |
| **InvShiftRows** | Desloca ciclicamente as linhas para a direita, nos mesmos deslocamentos usados por ShiftRows: 0, 1, 2 e 3 bytes. |
| **InvMixColumns** | Aplica a transformação matricial inversa em GF(2⁸) a cada coluna do estado. |

A matriz usada em **InvMixColumns** é:

|  |  |  |  |
| :---: | :---: | :---: | :---: |
| 0E | 0B | 0D | 09 |
| 09 | 0E | 0B | 0D |
| 0D | 09 | 0E | 0B |
| 0B | 0D | 09 | 0E |

Assim, a descriptografia não consiste apenas em executar o fluxo de criptografia ao contrário: ela utiliza as operações inversas correspondentes e a sequência de chaves de rodada em ordem inversa.

### Expansão de chave (*Key Expansion*)

A expansão de chave deriva as chaves de rodada a partir da chave original. A chave é tratada como palavras de 32 bits, e o algoritmo gera **4 × (Nr + 1)** palavras, agrupadas de quatro em quatro para formar as chaves de rodada de 128 bits.

| Variante | Palavras da chave original (Nk) | Palavras geradas | Chaves de rodada |
| :--- | :---: | :---: | :---: |
| AES-128 | 4 | 44 | 11 |
| AES-192 | 6 | 52 | 13 |
| AES-256 | 8 | 60 | 15 |

A expansão usa, entre outras operações, **RotWord** (rotação dos bytes de uma palavra), **SubWord** (aplicação da S-box aos bytes) e constantes de rodada (**Rcon**). No AES-256, há também uma aplicação adicional de SubWord em determinadas palavras do cronograma de chaves. Uma chave de rodada é usada antes das rodadas principais e cada uma das rodadas possui sua própria chave.

**Referência normativa:** [NIST, FIPS 197 — Advanced Encryption Standard (AES), versão atualizada em 2023](https://doi.org/10.6028/NIST.FIPS.197-upd1).

## Protocolo SPI

Protocolo síncrono, serial e full-duplex de transmissão de dados. Permite a conexão de vários dispositivos slave ao mesmo master. O dispositivo master é responsável por gerar o sinal de clock (SCK) e por gerenciar com qual dispositivo slave a comunicação ocorrerá em cada instante, através do sinal de seleção chip select/slave select (CS/SS). Normalmente a transmissão de um dado é feita de trás pra frente, com o MSB sendo transmitido primeiro, mas muitas controladoras SPI fornecem a opção de transmitir primeiramente o LSB.

### Barramento de sinais

| Sinal | Direção | Nome Extenso | Descrição |
| :--- | :--- | :--- | :--- |
| **SCK** | Master -> Slave | Serial Clock | Sinal de relógio gerado pelo master para sincronizar a transmissão e amostragem dos bits |
| **CS / SS** | Master -> Slave | Chip Select / Slave Select | Sinal ativo em nível lógico baixo que habilita um slave específico para comunicação |
| **MOSI / SDO** | Master -> Slave | Master Out, Slave In / Serial Data Out | Linha de transmissão de dados do master para o slave |
| **MISO / SDI** | Slave -> Master | Master In, Slave Out / Serial Data In | Linha de transmissão de dados do slave para o master. |

![alt text](image-1.png)

*Figura 1 - Diagrama de conexões entre dispositivos master e múltiplos slaves. Disponível em: [link](https://microcontroller-course.web.cern.ch/Peripherals/SPI.en/)*

Os sinais SCK, MOSI e MISO são comuns a todos os dispositivos do barramento. Cada slave possui seu próprio sinal CS dedicado. Caso o barramento possua N dispositivos slave, o master deverá disponibilizar N pinos de Chip Select.

### Vantagens

- Alta Velocidade: Frequências de clock podem ultrapassar dezenas de MHz (superior ao I2C e UART).
- Comunicação Full-Duplex: Envio e recebimento simultâneo de dados.
- Simplicidade de Hardware: Não exige circuitos complexos de transceptor nem gerenciamento de endereços no pacote.
- Flexibilidade de Dados: Não fica estritamente limitado a quadros de 8 bits (pode-se transferir 12, 16 ou mais bits por ciclo).

### Desvantagens

- Alto Consumo de Pinos: Exige 3 + N pinos de I/O no master para N escravos.
- Sem Confirmação de Recebimento (Ack/Nack): Não há verificação por hardware de que o dado foi entregue com sucesso.

### Modos de configuração SPI

**Modo 0:**
- SCK em repouso em nível lógico baixo
- Amostragem do bit nas linhas de dados MOSI/MISO em borda de subida do SCK

**Modo 1:**
- SCK em repouso em nível lógico baixo
- Amostragem do bit nas linhas de dados MOSI/MISO em borda de descida do SCK

**Modo 2:**
- SCK em repouso em nível lógico alto
- Amostragem do bit nas linhas de dados MOSI/MISO em borda de subida do SCK

**Modo 3:**
- SCK em repouso em nível lógico alto
- Amostragem do bit nas linhas de dados MOSI/MISO em borda de descida do SCK

![alt text](image.png)

*Figura 2 - Representação dos diferentes modos de configuração do SPI. Disponivel em: [link](https://www.mikroe.com/blog/spi-bus)*