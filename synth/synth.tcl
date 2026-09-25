# ============================================================
# Script de Síntese - SAED32_EDK
# Projeto: Vending Machine (SystemVerilog)
# ============================================================

set top_module "vending_top"

# 0. DIRETÓRIOS DE SAÍDA
set reports_dir "./synth/reports"
set netlist_dir "./synth/netlist"

if { ![file exists $reports_dir] } {
    file mkdir $reports_dir
}

if { ![file exists $netlist_dir] } {
    file mkdir $netlist_dir
}


# 1. CARREGAR CONFIGURAÇÃO
source ./synth/.synopsys_dc.setup

# 2. LER OS ARQUIVOS RTL
set rtl_files [concat  [glob -nocomplain ./rtl/pkg/*.sv] [glob -nocomplain ./rtl/*.sv]]
analyze -format sverilog $rtl_files

# 3. ELABORAR O DESIGN (Módulo Principal)
elaborate $top_module

# 4. LINKAR O DESIGN
link

# 5. Gerar o arquivo de netlist não mapeado
# (opcional, mas útil para depuração)
write_file -format verilog -hier -out [file join $netlist_dir vending_top_nao_mapeada.sv]

# 6. CARREGAR CONSTRAINTS
# Certifique-se de que o arquivo constraints.sdc existe na pasta scripts/
read_sdc synth/constraints.sdc

# 7. SÍNTESE
puts "\n============================================================"
puts "INICIANDO SÍNTESE (SystemVerilog)..."
puts "============================================================"

set_fix_hold [all_clocks]
set_ungroup [get_designs *] false
compile_ultra

# 8. RELATÓRIOS PÓS-SÍNTESE (SALVANDO NA PASTA REPORTS)
puts "\n=============================================================="
puts "RELATÓRIOS PÓS-SÍNTESE"
puts "=============================================================="

report_area -hierarchy > $reports_dir/area_pos.rpt
puts "\n--> Area: Relatorio salvo em: ./reports/area_pos.rpt"

report_timing > $reports_dir/timing_relatorio.rpt
puts "--> Timing: Relatorio salvo em: ./reports/timing_relatorio.rpt"

report_power > $reports_dir/power.rpt
puts "--> Power: Relatorio salvo em: ./reports/power.rpt"

# SETUP: report_constraint filtra por padrão violações de Max Delay (Setup)
report_constraint -all_violators > $reports_dir/setup_violations.rpt
puts "--> Setup Violations: Relatorio salvo em: $reports_dir/setup_violations.rpt"

# HOLD: Para reportar violações de Min Delay (Hold) no Design Compiler
report_constraint -all_violators -min_delay > $reports_dir/hold_violations.rpt
puts "--> Hold Violations: Relatorio salvo em: $reports_dir/hold_violations.rpt"

# 9. EXPORTAR NETLIST (SALVANDO NA PASTA NETLIST)
puts "\n=============================================================="
puts "NETLISTS GERADAS"
puts "=============================================================="

write -format verilog -hierarchy -output $netlist_dir/vending_top_mapeada.v
puts "\n--> Netlist Verilog salvo em: $netlist_dir/vending_top_mapeada.v"

write -format ddc -hierarchy -output $netlist_dir/vending_top_mapeada.ddc
puts "--> Netlist DDC salvo em: $netlist_dir/vending_top_mapeada.ddc"

# 11. FINALIZAR
puts "\n=============================================================="
puts "SINTESE CONCLUIDA COM SUCESSO!"
puts "=============================================================="
exit