onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {ERROR CHECK}
add wave -noupdate -group {ERROR CHECK} -format Logic /keyboard_tb/error
add wave -noupdate -group {ERROR CHECK} -format Logic /keyboard_tb/err2
add wave -noupdate -expand -group TOP
add wave -noupdate -group TOP -format Logic /keyboard_tb/clk
add wave -noupdate -group TOP -format Logic /keyboard_tb/rst
add wave -noupdate -group TOP -format Literal -radix hexadecimal /keyboard_tb/kbd_reg
add wave -noupdate -group TOP -format Logic /keyboard_tb/kbd_clk
add wave -noupdate -group TOP -format Logic /keyboard_tb/kbd_data
add wave -noupdate -group TOP -format Logic /keyboard_tb/clear
add wave -noupdate -group TOP -format Literal -radix hexadecimal /keyboard_tb/data
add wave -noupdate -group TOP -format Logic /keyboard_tb/rda
add wave -noupdate -expand -group KEYBOARD
add wave -noupdate -group KEYBOARD -format Logic /keyboard_tb/DUT/clear
add wave -noupdate -group KEYBOARD -format Logic /keyboard_tb/DUT/kbd_data
add wave -noupdate -group KEYBOARD -format Logic /keyboard_tb/DUT/kbd_clk
add wave -noupdate -group KEYBOARD -format Logic /keyboard_tb/DUT/rda
add wave -noupdate -group KEYBOARD -format Literal -radix hexadecimal /keyboard_tb/DUT/data
add wave -noupdate -group KEYBOARD -format Literal -radix hexadecimal /keyboard_tb/DUT/shiftreg
add wave -noupdate -group KEYBOARD -format Literal -radix hexadecimal /keyboard_tb/DUT/next_data
add wave -noupdate -group KEYBOARD -format Literal -radix unsigned /keyboard_tb/DUT/cnt
add wave -noupdate -group KEYBOARD -format Literal -radix unsigned /keyboard_tb/DUT/next_cnt
add wave -noupdate -group KEYBOARD -format Logic /keyboard_tb/DUT/state
add wave -noupdate -group KEYBOARD -format Logic /keyboard_tb/DUT/next_state
add wave -noupdate -group KEYBOARD -format Logic /keyboard_tb/DUT/next_rda
add wave -noupdate -group KEYBOARD -format Logic /keyboard_tb/DUT/parity
add wave -noupdate -group KEYBOARD -format Logic /keyboard_tb/DUT/valid_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1502056 ps} 0}
configure wave -namecolwidth 251
configure wave -valuecolwidth 101
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
WaveRestoreZoom {0 ps} {1926750 ps}
