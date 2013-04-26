onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group TESTBENCH
add wave -noupdate -group TESTBENCH -format Logic /mouse_tb/clk
add wave -noupdate -group TESTBENCH -format Logic /mouse_tb/rst
add wave -noupdate -group TESTBENCH -format Logic /mouse_tb/clk2
add wave -noupdate -group TESTBENCH -format Literal -radix hexadecimal /mouse_tb/mouse_reg
add wave -noupdate -group TESTBENCH -format Logic /mouse_tb/mouse_data
add wave -noupdate -group TESTBENCH -format Logic /mouse_tb/mouse_clk
add wave -noupdate -expand -group CNTR
add wave -noupdate -group CNTR -format Literal -radix unsigned /mouse_tb/DUT/state
add wave -noupdate -group CNTR -format Literal -radix unsigned /mouse_tb/DUT/step
add wave -noupdate -group CNTR -format Literal -radix hexadecimal /mouse_tb/DUT/data
add wave -noupdate -group CNTR -format Logic /mouse_tb/DUT/rda
add wave -noupdate -group CNTR -format Logic /mouse_tb/DUT/sent
add wave -noupdate -group CNTR -format Logic /mouse_tb/DUT/ignore_rda
add wave -noupdate -group CNTR -format Logic /mouse_tb/DUT/set_ignore
add wave -noupdate -group CNTR -format Logic /mouse_tb/DUT/rst_ignore
add wave -noupdate -group CNTR -format Logic /mouse_tb/DUT/shift_val_in
add wave -noupdate -group CNTR -format Logic /mouse_tb/DUT/tbr
add wave -noupdate -group CNTR -format Literal -radix unsigned /mouse_tb/DUT/rdn
add wave -noupdate -group CNTR -divider regs
add wave -noupdate -group CNTR -format Literal -radix hexadecimal /mouse_tb/DUT/reg1
add wave -noupdate -group CNTR -format Literal -radix hexadecimal /mouse_tb/DUT/reg2
add wave -noupdate -group CNTR -format Literal -radix hexadecimal /mouse_tb/DUT/reg3
add wave -noupdate -group CNTR -format Literal -radix hexadecimal /mouse_tb/DUT/reg4
add wave -noupdate -group CNTR -format Literal -radix hexadecimal /mouse_tb/DUT/reg5
add wave -noupdate -group CNTR -format Literal -radix hexadecimal /mouse_tb/DUT/reg6
add wave -noupdate -group CNTR -format Literal -radix hexadecimal /mouse_tb/DUT/reg7
add wave -noupdate -group CNTR -format Literal -radix hexadecimal /mouse_tb/DUT/reg8
add wave -noupdate -group CNTR -format Literal -radix hexadecimal /mouse_tb/DUT/tx_data
add wave -noupdate -expand -group MOUSE
add wave -noupdate -group MOUSE -format Literal -radix unsigned /mouse_tb/DUT/m0/state
add wave -noupdate -group MOUSE -format Literal -radix unsigned /mouse_tb/DUT/m0/hold_cnt
add wave -noupdate -group MOUSE -format Logic /mouse_tb/DUT/m0/rda
add wave -noupdate -group MOUSE -format Literal -radix hexadecimal /mouse_tb/DUT/m0/data
add wave -noupdate -group MOUSE -format Logic /mouse_tb/DUT/m0/tbr
add wave -noupdate -group MOUSE -format Literal -radix hexadecimal /mouse_tb/DUT/m0/tx_data
add wave -noupdate -group MOUSE -format Logic /mouse_tb/DUT/m0/sent
add wave -noupdate -group MOUSE -format Literal -radix hexadecimal /mouse_tb/DUT/m0/shiftreg
add wave -noupdate -group MOUSE -format Literal -radix unsigned /mouse_tb/DUT/m0/cnt
add wave -noupdate -group MOUSE -format Logic /mouse_tb/DUT/m0/parity
add wave -noupdate -group MOUSE -format Logic /mouse_tb/DUT/m0/drive_data
add wave -noupdate -group MOUSE -format Logic /mouse_tb/DUT/m0/drive_clk
add wave -noupdate -group MOUSE -format Logic /mouse_tb/DUT/m0/rst_latch
add wave -noupdate -group MOUSE -format Logic /mouse_tb/DUT/m0/valid_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 236
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {468921890 ps} {501740954 ps}
