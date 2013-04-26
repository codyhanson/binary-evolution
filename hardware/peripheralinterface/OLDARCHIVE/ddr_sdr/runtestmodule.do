vlib work
vcom -93 ddr_sdr_conf_pkg.vhd reset.vhd ddr_dcm.vhd user_if.vhd ddr_sdr.vhd mt46v16m16.vhd tb.vhd

vsim -t ps tb
view wave
add wave *
run -all
