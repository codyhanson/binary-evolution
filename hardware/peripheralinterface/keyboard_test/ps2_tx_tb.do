onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group TESTBENCH
add wave -noupdate -group TESTBENCH -format Logic /ps2_tx_tb/clk
add wave -noupdate -group TESTBENCH -format Logic /ps2_tx_tb/rst
add wave -noupdate -group TESTBENCH -format Logic /ps2_tx_tb/ps2_data
add wave -noupdate -group TESTBENCH -format Logic /ps2_tx_tb/ps2_clk
add wave -noupdate -group TESTBENCH -format Literal /ps2_tx_tb/data
add wave -noupdate -group TESTBENCH -format Logic /ps2_tx_tb/sent
add wave -noupdate -group TESTBENCH -format Logic /ps2_tx_tb/tbr
add wave -noupdate -expand -group DUT
add wave -noupdate -group DUT -format Logic /ps2_tx_tb/DUT/clk
add wave -noupdate -group DUT -format Logic /ps2_tx_tb/DUT/rst
add wave -noupdate -group DUT -format Logic /ps2_tx_tb/DUT/ps2_data
add wave -noupdate -group DUT -format Logic /ps2_tx_tb/DUT/ps2_clk
add wave -noupdate -group DUT -format Logic /ps2_tx_tb/DUT/tx_en
add wave -noupdate -group DUT -format Logic /ps2_tx_tb/DUT/tbr
add wave -noupdate -group DUT -format Literal -radix hexadecimal /ps2_tx_tb/DUT/data
add wave -noupdate -group DUT -format Logic /ps2_tx_tb/DUT/sent
add wave -noupdate -group DUT -format Literal -radix hexadecimal /ps2_tx_tb/DUT/shiftreg
add wave -noupdate -group DUT -format Literal -radix hexadecimal /ps2_tx_tb/DUT/next_shiftreg
add wave -noupdate -group DUT -format Literal -radix unsigned /ps2_tx_tb/DUT/state
add wave -noupdate -group DUT -format Literal -radix unsigned /ps2_tx_tb/DUT/next_state
add wave -noupdate -group DUT -format Literal -radix unsigned /ps2_tx_tb/DUT/hold_cnt
add wave -noupdate -group DUT -format Literal -radix unsigned /ps2_tx_tb/DUT/next_hold
add wave -noupdate -group DUT -format Literal -radix unsigned /ps2_tx_tb/DUT/cnt
add wave -noupdate -group DUT -format Literal -radix unsigned /ps2_tx_tb/DUT/next_cnt
add wave -noupdate -group DUT -format Logic /ps2_tx_tb/DUT/data_out
add wave -noupdate -group DUT -format Logic /ps2_tx_tb/DUT/clk_out
add wave -noupdate -group DUT -format Logic /ps2_tx_tb/DUT/next_sent
add wave -noupdate -group DUT -format Literal /ps2_tx_tb/DUT/clk_buf
add wave -noupdate -group DUT -format Logic /ps2_tx_tb/DUT/fall_edge
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 212
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
WaveRestoreZoom {0 ps} {1538802 ps}
