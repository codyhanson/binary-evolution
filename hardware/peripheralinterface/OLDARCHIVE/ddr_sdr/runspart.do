vlib work
vcom -93 ddr_sdr_conf_pkg.vhd reset.vhd ddr_dcm.vhd user_if.vhd ddr_sdr.vhd mt46v16m16.vhd tb.vhd
vcom mini_spart/*.v

vsim -t ps rx_spart_tb
view wave
add wave *
run -all
