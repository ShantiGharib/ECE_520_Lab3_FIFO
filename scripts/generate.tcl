set proj_name ECE_520_Lab3_FIFO
set current_dir [file normalize [file dirname [info script]]]
set repo_dir [file dirname $current_dir]
set proj_dir [file join $repo_dir $proj_name]

if {[file exists $proj_dir]} {
    error "$proj_name/ already exists at $proj_dir. Remove it before re-running this script."
}

# set part_id xc7z010clg400-1
set part_id xc7z020clg400-1
create_project $proj_name $proj_dir -part $part_id

set repo_scripts_dir [file join $repo_dir scripts]
set proj_scripts_dir [file join $proj_dir scripts]
set python_filepath [file join $repo_scripts_dir generate_FIFO_data.py]
file mkdir $proj_scripts_dir
if {[file exists $python_filepath]} {
	file copy -force $python_filepath $proj_scripts_dir
}

set repo_sim_dir [file join $repo_dir sim]
set proj_sim_dir [file join $proj_dir sim]
file mkdir $proj_sim_dir
set input_data_path [file join $repo_dir sim input_data.txt]
set input_data_writes_only_path [file join $repo_dir sim input_data_writes_only.txt]
if {![file exists $input_data_path] || ![file exists $input_data_writes_only_path]} {
	if {![file exists $python_filepath]} {
		error "missing python data generation source and/or already generated data for testbench. Either add already generated test data to $repo_dir/sim or add python script to $repo_dir/scripts before re-running this script"
	} else {
		puts "WARNING: sim won't be able to run without providing generated test data to $proj_sim_dir"
	}
} else {
	file copy -force $input_data_path $proj_sim_dir
	file copy -force $input_data_writes_only_path $proj_sim_dir
}

# set language_name Verilog
set language_name VHDL
set_property target_language $language_name [current_project]
set_property simulator_language $language_name [current_project]

# set board_part [lindex [get_board_parts -quiet "digilentinc.com:zybo-z7-10:part0:*"] 0]
set board_part [lindex [get_board_parts -quiet "digilentinc.com:zybo-z7-20:part0:*"] 0]
if {$board_part ne ""} {
    set_property board_part $board_part [current_project]
}

# set extension .v
set extension .vhd

set repo_src_files [glob -nocomplain [file join $repo_dir src *$extension]]
set proj_src_files_dir [file join $proj_dir "$proj_name.srcs" sources_1 new]
file mkdir $proj_src_files_dir
foreach found_file $repo_src_files {
	file copy -force $found_file $proj_src_files_dir
}
set proj_src_files [glob -nocomplain [file join $proj_src_files_dir *$extension]]
add_files -norecurse $proj_src_files

set top_filename fifo.vhd
set_property top $top_filename [current_fileset]


set repo_sim_files [glob -nocomplain [file join $repo_dir sim *$extension]]
set proj_sim_files_dir [file join $proj_dir "$proj_name.srcs" sim_1 new]
file mkdir $proj_sim_files_dir
foreach found_file $repo_sim_files {
	file copy -force $found_file $proj_sim_files_dir
}
set proj_sim_files [glob -nocomplain [file join $proj_sim_files_dir *$extension]]
add_files -fileset sim_1 -norecurse $proj_sim_files

set testbench_name fifo_tb_random.vhd
set_property top $testbench_name [get_filesets sim_1]


set_property file_type {VHDL 2008} [get_files *$extension]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

set sim_run_dir [file join $proj_dir "$proj_name.sim" sim_1 behav xsim]
file mkdir $sim_run_dir