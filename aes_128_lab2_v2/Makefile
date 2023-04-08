tb_aes:
	vcs -sverilog -R +lint=all -debug_access+all -top aes_tb +incdir+include +lint=all *.v -gui
clean:
	rm -rf simv.daidir/
	rm -rf simv
	rm -rf csrc
	rm -rf DVEfiles
	rm -f ucli.key
	rm -f inter.vpd
	rm -f .restartSimSession.tcl.old


all: clean tb_aes
