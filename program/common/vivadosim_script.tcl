# set include directories
set_property include_dirs {../../../src/ ../../../testbench/} [current_fileset]

# add our program to simulation fileset
add_files -fileset sim_1 program.hex

# read design files
read_verilog [glob ../../../src/*.v ]

# read testbench
read_verilog [glob ../../../testbench/*.v]

# save project in sim folder
save_project_as sim -force

# set top module
set_property top sm_testbench [get_fileset sim_1]

# launch simulation
launch_simulation -simset sim_1 -mode behavioral

# run simulation until done
run -all