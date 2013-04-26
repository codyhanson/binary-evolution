all : clean asm

asm :
	./asm.pl assembled_progs/gol/gol gol/main_menu.s gol/gol_main.s gol/setup_lut.s gol/proc_1_generation.s gol/proc_nbrhd.s gol/proc_no_nbrhd.s gol/switch_fb.s gol/set_fb.s gol/clear_board.s gol/copy_fb.s gol/plot_obj.s gol/menu_setup.s gol/bcd_to_bin.s gol/make_border.s gol/imageproc.s gol/filters.s gol/invert_board.s gol/appdata.data

sim :
	./sim.pl dump/gol gol/main_menu.s gol/gol_main.s gol/proc_1_generation.s gol/setup_lut.s gol/proc_nbrhd.s gol/proc_no_nbrhd.s gol/switch_fb.s gol/set_fb.s gol/clear_board.s gol/copy_fb.s gol/plot_obj.s gol/menu_setup.s gol/bcd_to_bin.s gol/make_border.s gol/imageproc.s gol/filters.s gol/invert_board.s gol/appdata.data

simq :
	./sim.pl dump/gol gol/main_menu.s gol/gol_main.s gol/proc_1_generation.s gol/setup_lut.s gol/proc_nbrhd.s gol/proc_no_nbrhd.s gol/switch_fb.s gol/set_fb.s gol/clear_board.s gol/copy_fb.s gol/plot_obj.s gol/menu_setup.s gol/bcd_to_bin.s gol/make_border.s gol/imageproc.s gol/filters.s gol/invert_board.s gol/appdata.data --q

clean :
	rm assembled_progs/gol/* -rf;
	rm dump/gol/* -rf
