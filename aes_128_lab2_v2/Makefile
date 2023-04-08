tb_aes:
	vcs -sverilog -R +lint=all -debug_access+all -top aes_tb +incdir+include +lint=all *.v
clean:
	rm -rf simv.daidir/
	rm -rf simv

all: clean tb_aes
