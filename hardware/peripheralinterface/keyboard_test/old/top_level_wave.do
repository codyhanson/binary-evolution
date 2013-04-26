onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group TOP
add wave -noupdate -group TOP -format Logic /top_level_tb/clk
add wave -noupdate -group TOP -format Logic /top_level_tb/clk2
add wave -noupdate -group TOP -format Logic /top_level_tb/rst
add wave -noupdate -group TOP -format Literal -radix hexadecimal /top_level_tb/kbd_reg
add wave -noupdate -group TOP -format Logic /top_level_tb/kbd_clk
add wave -noupdate -group TOP -format Logic /top_level_tb/kbd_data
add wave -noupdate -group TOP -format Logic /top_level_tb/error
add wave -noupdate -group TOP -format Logic /top_level_tb/err2
add wave -noupdate -group TOP -format Literal /top_level_tb/br_cfg
add wave -noupdate -group TOP -format Logic /top_level_tb/txd
add wave -noupdate -group TOP -format Logic /top_level_tb/rxd
add wave -noupdate -expand -group KEYBOARD
add wave -noupdate -group KEYBOARD -format Logic /top_level_tb/DUT/keyboard0/clk
add wave -noupdate -group KEYBOARD -format Logic /top_level_tb/DUT/keyboard0/rst
add wave -noupdate -group KEYBOARD -format Logic /top_level_tb/DUT/keyboard0/clear
add wave -noupdate -group KEYBOARD -format Logic /top_level_tb/DUT/keyboard0/kbd_data
add wave -noupdate -group KEYBOARD -format Logic /top_level_tb/DUT/keyboard0/kbd_clk
add wave -noupdate -group KEYBOARD -format Logic /top_level_tb/DUT/keyboard0/rda
add wave -noupdate -group KEYBOARD -format Literal -radix hexadecimal /top_level_tb/DUT/keyboard0/data
add wave -noupdate -group KEYBOARD -format Literal -radix hexadecimal /top_level_tb/DUT/keyboard0/shift_reg
add wave -noupdate -group KEYBOARD -format Literal -radix hexadecimal /top_level_tb/DUT/keyboard0/shift_reg_next
add wave -noupdate -group KEYBOARD -format Literal -radix hexadecimal /top_level_tb/DUT/keyboard0/count
add wave -noupdate -group KEYBOARD -format Literal -radix hexadecimal /top_level_tb/DUT/keyboard0/count_next
add wave -noupdate -group KEYBOARD -format Logic /top_level_tb/DUT/keyboard0/state
add wave -noupdate -group KEYBOARD -format Logic /top_level_tb/DUT/keyboard0/state_next
add wave -noupdate -group KEYBOARD -format Logic /top_level_tb/DUT/keyboard0/parity
add wave -noupdate -group KEYBOARD -format Logic /top_level_tb/DUT/keyboard0/parity_next
add wave -noupdate -group KEYBOARD -format Logic /top_level_tb/DUT/keyboard0/sample_rdy
add wave -noupdate -group KEYBOARD -format Logic /top_level_tb/DUT/keyboard0/sample_rdy_next
add wave -noupdate -group KEYBOARD -format Logic /top_level_tb/DUT/keyboard0/rda_next
add wave -noupdate -expand -group SPART
add wave -noupdate -group SPART -format Logic /top_level_tb/DUT/spart0/rda
add wave -noupdate -group SPART -format Literal -radix hexadecimal /top_level_tb/DUT/spart0/rx_databus
add wave -noupdate -group SPART -format Logic /top_level_tb/DUT/spart0/clk
add wave -noupdate -group SPART -format Logic /top_level_tb/DUT/spart0/rst
add wave -noupdate -group SPART -format Logic /top_level_tb/DUT/spart0/iocs
add wave -noupdate -group SPART -format Logic /top_level_tb/DUT/spart0/iorw
add wave -noupdate -group SPART -format Logic /top_level_tb/DUT/spart0/tbr
add wave -noupdate -group SPART -format Literal /top_level_tb/DUT/spart0/ioaddr
add wave -noupdate -group SPART -format Literal -radix hexadecimal /top_level_tb/DUT/spart0/databus
add wave -noupdate -group SPART -format Logic /top_level_tb/DUT/spart0/txd
add wave -noupdate -group SPART -format Logic /top_level_tb/DUT/spart0/rxd
add wave -noupdate -group SPART -format Logic /top_level_tb/DUT/spart0/brg_en
add wave -noupdate -group SPART -format Logic /top_level_tb/DUT/spart0/brg_full
add wave -noupdate -group SPART -format Logic /top_level_tb/DUT/spart0/clear_rda
add wave -noupdate -group SPART -format Logic /top_level_tb/DUT/spart0/rx_tri_en
add wave -noupdate -group SPART -format Logic /top_level_tb/DUT/spart0/status_tri_en
add wave -noupdate -expand -group DRIVER
add wave -noupdate -group DRIVER -format Literal /top_level_tb/DUT/driver0/state
add wave -noupdate -group DRIVER -format Logic /top_level_tb/DUT/driver0/clk
add wave -noupdate -group DRIVER -format Logic /top_level_tb/DUT/driver0/rst
add wave -noupdate -group DRIVER -format Literal /top_level_tb/DUT/driver0/br_cfg
add wave -noupdate -group DRIVER -format Logic /top_level_tb/DUT/driver0/iocs
add wave -noupdate -group DRIVER -format Logic /top_level_tb/DUT/driver0/iorw
add wave -noupdate -group DRIVER -format Logic /top_level_tb/DUT/driver0/kbd_rda
add wave -noupdate -group DRIVER -format Logic /top_level_tb/DUT/driver0/clear_kbd
add wave -noupdate -group DRIVER -format Logic /top_level_tb/DUT/driver0/tbr
add wave -noupdate -group DRIVER -format Literal /top_level_tb/DUT/driver0/ioaddr
add wave -noupdate -group DRIVER -format Literal -radix hexadecimal /top_level_tb/DUT/driver0/databus
add wave -noupdate -group DRIVER -format Literal -radix hexadecimal /top_level_tb/DUT/driver0/kbd_databus
add wave -noupdate -group DRIVER -format Literal -radix hexadecimal /top_level_tb/DUT/driver0/databus_reg
add wave -noupdate -group DRIVER -format Literal /top_level_tb/DUT/driver0/state_next
add wave -noupdate -group DRIVER -format Literal -radix hexadecimal /top_level_tb/DUT/driver0/rcv_buf
add wave -noupdate -group DRIVER -format Literal -radix hexadecimal /top_level_tb/DUT/driver0/rcv_buf_next
add wave -noupdate -group DRIVER -format Logic /top_level_tb/DUT/driver0/data_en
add wave -noupdate -group DRIVER -format Literal -radix hexadecimal /top_level_tb/DUT/driver0/brg_hi
add wave -noupdate -group DRIVER -format Literal -radix hexadecimal /top_level_tb/DUT/driver0/brg_lo
add wave -noupdate -group DRIVER -format Logic /top_level_tb/DUT/driver0/next_clear_kbd
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 308
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
update
WaveRestoreZoom {0 ps} {1050010500 ps}
