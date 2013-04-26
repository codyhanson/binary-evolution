onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group DUT
add wave -noupdate -group DUT -format Logic -radix hexadecimal /top_level_tb/DUT/clk
add wave -noupdate -group DUT -format Logic -radix hexadecimal /top_level_tb/DUT/rst
add wave -noupdate -group DUT -format Logic -radix hexadecimal /top_level_tb/DUT/txd
add wave -noupdate -group DUT -format Logic -radix hexadecimal /top_level_tb/DUT/rxd
add wave -noupdate -group DUT -format Literal -radix hexadecimal /top_level_tb/DUT/br_cfg
add wave -noupdate -group DUT -format Logic -radix hexadecimal /top_level_tb/DUT/iocs
add wave -noupdate -group DUT -format Logic -radix hexadecimal /top_level_tb/DUT/iorw
add wave -noupdate -group DUT -format Logic -radix hexadecimal /top_level_tb/DUT/rda
add wave -noupdate -group DUT -format Logic -radix hexadecimal /top_level_tb/DUT/tbr
add wave -noupdate -group DUT -format Literal -radix hexadecimal /top_level_tb/DUT/ioaddr
add wave -noupdate -group DUT -format Literal -radix hexadecimal /top_level_tb/DUT/databus
add wave -noupdate -format Logic -radix hexadecimal /top_level_tb/clk
add wave -noupdate -format Logic -radix hexadecimal /top_level_tb/rst
add wave -noupdate -format Literal -radix hexadecimal /top_level_tb/br_cfg
add wave -noupdate -format Logic -radix hexadecimal /top_level_tb/rxd_txd
add wave -noupdate -expand -group Driver
add wave -noupdate -group Driver -format Logic -radix hexadecimal /top_level_tb/DUT/driver0/iorw
add wave -noupdate -group Driver -format Logic -radix hexadecimal /top_level_tb/DUT/driver0/rda
add wave -noupdate -group Driver -format Logic -radix hexadecimal /top_level_tb/DUT/driver0/tbr
add wave -noupdate -group Driver -format Literal -radix hexadecimal /top_level_tb/DUT/driver0/ioaddr
add wave -noupdate -group Driver -format Literal -radix hexadecimal /top_level_tb/DUT/driver0/databus
add wave -noupdate -group Driver -format Literal -radix hexadecimal /top_level_tb/DUT/driver0/databus_reg
add wave -noupdate -group Driver -format Literal -radix hexadecimal /top_level_tb/DUT/driver0/state
add wave -noupdate -group Driver -format Literal -radix hexadecimal /top_level_tb/DUT/driver0/state_next
add wave -noupdate -group Driver -format Literal -radix hexadecimal /top_level_tb/DUT/driver0/rcv_buf
add wave -noupdate -group Driver -format Literal -radix hexadecimal /top_level_tb/DUT/driver0/rcv_buf_next
add wave -noupdate -group Driver -format Literal -radix hexadecimal /top_level_tb/DUT/driver0/brg_hi
add wave -noupdate -group Driver -format Literal -radix hexadecimal /top_level_tb/DUT/driver0/brg_lo
add wave -noupdate -expand -group SPART
add wave -noupdate -group SPART -format Logic -radix hexadecimal /top_level_tb/DUT/spart0/clk
add wave -noupdate -group SPART -format Logic -radix hexadecimal /top_level_tb/DUT/spart0/rst
add wave -noupdate -group SPART -format Logic -radix hexadecimal /top_level_tb/DUT/spart0/iocs
add wave -noupdate -group SPART -format Logic -radix hexadecimal /top_level_tb/DUT/spart0/iorw
add wave -noupdate -group SPART -format Logic -radix hexadecimal /top_level_tb/DUT/spart0/rda
add wave -noupdate -group SPART -format Logic -radix hexadecimal /top_level_tb/DUT/spart0/tbr
add wave -noupdate -group SPART -format Literal -radix hexadecimal /top_level_tb/DUT/spart0/ioaddr
add wave -noupdate -group SPART -format Literal -radix hexadecimal /top_level_tb/DUT/spart0/databus
add wave -noupdate -group SPART -format Logic -radix hexadecimal /top_level_tb/DUT/spart0/txd
add wave -noupdate -group SPART -format Logic -radix hexadecimal /top_level_tb/DUT/spart0/rxd
add wave -noupdate -group SPART -format Literal -radix hexadecimal /top_level_tb/DUT/spart0/rx_databus
add wave -noupdate -group SPART -format Logic -radix hexadecimal /top_level_tb/DUT/spart0/brg_en
add wave -noupdate -group SPART -format Logic -radix hexadecimal /top_level_tb/DUT/spart0/brg_full
add wave -noupdate -group SPART -format Logic -radix hexadecimal /top_level_tb/DUT/spart0/rx_tri_en
add wave -noupdate -group SPART -format Logic -radix hexadecimal /top_level_tb/DUT/spart0/status_tri_en
add wave -noupdate -expand -group BRG
add wave -noupdate -group BRG -format Literal -radix hexadecimal /top_level_tb/DUT/spart0/brg/databus
add wave -noupdate -group BRG -format Logic -radix hexadecimal /top_level_tb/DUT/spart0/brg/clk
add wave -noupdate -group BRG -format Logic -radix hexadecimal /top_level_tb/DUT/spart0/brg/rst
add wave -noupdate -group BRG -format Literal -radix hexadecimal /top_level_tb/DUT/spart0/brg/ioaddr
add wave -noupdate -group BRG -format Logic -radix hexadecimal /top_level_tb/DUT/spart0/brg/brg_en
add wave -noupdate -group BRG -format Logic -radix hexadecimal /top_level_tb/DUT/spart0/brg/brg_full
add wave -noupdate -group BRG -format Literal -radix hexadecimal /top_level_tb/DUT/spart0/brg/div_buffer
add wave -noupdate -group BRG -format Literal -radix hexadecimal /top_level_tb/DUT/spart0/brg/div_buffer_next
add wave -noupdate -group BRG -format Literal -radix hexadecimal /top_level_tb/DUT/spart0/brg/full_cnt
add wave -noupdate -group BRG -format Literal -radix hexadecimal /top_level_tb/DUT/spart0/brg/full_cnt_next
add wave -noupdate -group BRG -format Literal -radix hexadecimal /top_level_tb/DUT/spart0/brg/cnt
add wave -noupdate -group BRG -format Literal -radix hexadecimal /top_level_tb/DUT/spart0/brg/cnt_next
add wave -noupdate -group BRG -format Logic -radix hexadecimal /top_level_tb/DUT/spart0/brg/zero
add wave -noupdate -expand -group TX
add wave -noupdate -group TX -format Logic -radix hexadecimal /top_level_tb/DUT/spart0/tx/txd
add wave -noupdate -group TX -format Logic -radix hexadecimal /top_level_tb/DUT/spart0/tx/tbr
add wave -noupdate -group TX -format Logic -radix hexadecimal /top_level_tb/DUT/spart0/tx/clk
add wave -noupdate -group TX -format Logic -radix hexadecimal /top_level_tb/DUT/spart0/tx/rst
add wave -noupdate -group TX -format Logic -radix hexadecimal /top_level_tb/DUT/spart0/tx/iorw
add wave -noupdate -group TX -format Logic -radix hexadecimal /top_level_tb/DUT/spart0/tx/brg_full
add wave -noupdate -group TX -format Literal -radix hexadecimal /top_level_tb/DUT/spart0/tx/databus
add wave -noupdate -group TX -format Literal -radix hexadecimal /top_level_tb/DUT/spart0/tx/ioaddr
add wave -noupdate -group TX -format Literal -radix binary /top_level_tb/DUT/spart0/tx/tx_shift_reg
add wave -noupdate -group TX -format Literal -radix hexadecimal /top_level_tb/DUT/spart0/tx/tx_shift_reg_next
add wave -noupdate -group TX -format Logic -radix hexadecimal /top_level_tb/DUT/spart0/tx/state
add wave -noupdate -group TX -format Logic -radix hexadecimal /top_level_tb/DUT/spart0/tx/state_next
add wave -noupdate -group TX -format Literal -radix hexadecimal /top_level_tb/DUT/spart0/tx/tx_count
add wave -noupdate -group TX -format Literal -radix hexadecimal /top_level_tb/DUT/spart0/tx/tx_count_next
add wave -noupdate -expand -group RX
add wave -noupdate -group RX -format Logic -radix hexadecimal /top_level_tb/DUT/spart0/rx/rda
add wave -noupdate -group RX -format Logic -radix hexadecimal /top_level_tb/DUT/spart0/rx/clk
add wave -noupdate -group RX -format Logic -radix hexadecimal /top_level_tb/DUT/spart0/rx/rst
add wave -noupdate -group RX -format Logic -radix hexadecimal /top_level_tb/DUT/spart0/rx/brg_en
add wave -noupdate -group RX -format Logic -radix hexadecimal /top_level_tb/DUT/spart0/rx/brg_full
add wave -noupdate -group RX -format Logic -radix hexadecimal /top_level_tb/DUT/spart0/rx/rxd
add wave -noupdate -group RX -format Literal -radix hexadecimal /top_level_tb/DUT/spart0/rx/databus
add wave -noupdate -group RX -format Literal -radix hexadecimal /top_level_tb/DUT/spart0/rx/ioaddr
add wave -noupdate -group RX -format Logic -radix hexadecimal /top_level_tb/DUT/spart0/rx/state
add wave -noupdate -group RX -format Logic -radix hexadecimal /top_level_tb/DUT/spart0/rx/state_next
add wave -noupdate -group RX -format Literal -radix hexadecimal /top_level_tb/DUT/spart0/rx/rx_count
add wave -noupdate -group RX -format Literal -radix hexadecimal /top_level_tb/DUT/spart0/rx/rx_count_next
add wave -noupdate -group RX -format Literal -radix hexadecimal /top_level_tb/DUT/spart0/rx/sample_accum
add wave -noupdate -group RX -format Literal -radix hexadecimal /top_level_tb/DUT/spart0/rx/sample_accum_next
add wave -noupdate -group RX -format Literal -radix hexadecimal /top_level_tb/DUT/spart0/rx/rx_shift_reg
add wave -noupdate -group RX -format Literal -radix hexadecimal /top_level_tb/DUT/spart0/rx/rx_shift_reg_next
add wave -noupdate -group RX -format Logic -radix hexadecimal /top_level_tb/DUT/spart0/rx/rxd_sync
add wave -noupdate -group RX -format Logic -radix hexadecimal /top_level_tb/DUT/spart0/rx/rxd_flop1
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2144534 ps} 0}
configure wave -namecolwidth 306
configure wave -valuecolwidth 66
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
WaveRestoreZoom {935516 ps} {3116088 ps}
