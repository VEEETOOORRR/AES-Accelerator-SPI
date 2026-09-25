# ==========================================
# Diretórios
# ==========================================
RTL_DIR = rtl
TB_DIR  = sim
SCRIPTS_DIR = synth
REPORTS_DIR = $(SCRIPTS_DIR)/reports
NETLIST_DIR = $(SCRIPTS_DIR)/netlist
# ==========================================
# Arquivos
# ==========================================
RTL_FILES = $(RTL_DIR)/*.sv
TB_FILES  = $(TB_DIR)/*.sv
PKG_FILES = $(RTL_DIR)/pkg/*.sv

# Top do testbench
TOP = top_module
NETLIST_FILE = $(NETLIST_DIR)/netlist_top_mapeada.v
SIMV_POST_SYNTH = simv_post_synth
LIBRARY_FILE = libs/saed32nm.v

# ==========================================
# 1. Parâmetros de cada ferramenta
# ==========================================
VLOGAN_PARAMS = -full64 \
				-sverilog \
				-timescale=1ns/1ps \
				-kdb \
				+lint=all

VCS_PARAMS = -full64 \
			 -timescale=1ns/1ps \
			 -debug_access+all \
			 -kdb \
			 +notimingchecks \
             +nospecify

# ==========================================
# 1. Verificação de sintaxe
# ==========================================
syntax:
	vlogan $(VLOGAN_PARAMS) $(PKG_FILES) $(RTL_FILES) $(TB_FILES)

# ==========================================
# 2. Compilação / Elaboração
# ==========================================
compile: syntax
	vcs $(VCS_PARAMS) $(TOP)
# ==========================================
# 3. Rodar simulação
# ==========================================
run: compile
	./simv

# ==========================================
# Abrir waveform no Verdi
# ==========================================
wave:
	verdi -ssf waves.fsdb &

# ==========================================
# Síntese
# ==========================================
synth:
	dc_shell -f $(SCRIPTS_DIR)/synth.tcl

# ==========================================
# Simulação pós síntese
# ==========================================
sim_netlist: clean_sim synth
	vlogan $(VLOGAN_PARAMS) $(PKG_FILES) $(LIBRARY_FILE) $(NETLIST_FILE) $(TB_FILES)
	vcs $(VCS_PARAMS) $(TOP) -o $(SIMV_POST_SYNTH)
	./$(SIMV_POST_SYNTH)

# ==========================================
# Limpeza da síntese
# ==========================================
clean_synth:
	rm -rf \
		./accumulator.ddc \
		./alib-52 \
		./default.svf \
		./work* \
		$(SYNTH_DIR)/*.rpt \
		$(SYNTH_DIR)/*.ddc \
		$(SYNTH_DIR)/*.db \
		$(SYNTH_DIR)/*_syn.v \
		$(NETLIST_DIR) \
		$(REPORTS_DIR)

# ==========================================
# Limpeza da simulação
# ==========================================
clean_sim:
	rm -rf \
		csrc \
		simv* \
		*.daidir \
		novas* \
		AN.DB \
		ucli.key \
		verdi* \
		DVEfiles \
		.vlogan* \
		*.fsdb \
		*.log \
		vfastLog

# ==========================================
# Limpeza total
# ==========================================
clean: clean_sim clean_synth

.PHONY: syntax compile run wave synth clean clean_sim clean_synth