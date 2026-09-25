# ============================================================
# Arquivo de Restrições (SDC) - Vending Machine
# ============================================================

# 1. Definição do Clock Principal
create_clock -name clk -period 6.2 [get_ports clk]

# 2. Incerteza do Clock (Jitter/Skew)
set_clock_uncertainty 0.5 [get_clocks clk]

# 3. Atrasos de Entrada e Saída (I/O Delays)
set_input_delay 2 -clock clk [all_inputs]
set_output_delay 3 -clock clk [all_outputs]

# Restrição de Área
#set_max_area 0.0

# 4. Transição Máxima
# Garante que os sinais não demorem muito para ir de 0 a 1 (evita curtos-circuitos internos).
set_max_transition 1.5 [current_design]

# Definir o driver das entradas
set_driving_cell -lib_cell INVX2 -pin Y [remove_from_collection [all_inputs] [get_ports clk]]

# Definir um driver mais forte para a entrada de clock
set_driving_cell -lib_cell BUFFX4 -pin Y [get_ports clk]

# Aplica uma carga de 10 fF (femtofarads) em todas as saídas
set_load 0.010 [all_outputs]
