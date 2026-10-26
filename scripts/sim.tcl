set proj_name ECE_520_Lab3_FIFO
set current_dir [file normalize [file dirname [info script]]]
set repo_dir [file dirname $current_dir]
set proj_dir [file join $repo_dir $proj_name]

set input_data_path [file join $proj_dir sim input_data.txt]
set input_data_writes_only_path [file join $proj_dir sim input_data_writes_only.txt]
if {![file exists $input_data_path] || ![file exists $input_data_writes_only_path]} {
    error "Run scripts/generate_mult_data.py first."
}

set xpr_files [glob -nocomplain [file join $proj_dir *.xpr]]
if {[llength $xpr_files] == 0} {
    error "No Vivado project found in $proj_dir. Run generate.tcl first."
}
open_project [lindex $xpr_files 0]

launch_simulation -simset sim_1 -mode behavioral

set proj_name [get_property NAME [current_project]]
set sim_run_dir [file join $proj_dir "$proj_name.sim" sim_1 behav xsim]
if {![file exists $sim_run_dir]} {
    error "Expected simulation run directory not found: $sim_run_dir"
}
file copy -force $input_data_path $sim_run_dir

run all

set results_path [file join $sim_run_dir test_results.txt]
if {[file exists $results_path]} {
    file copy -force $results_path [file join $repo_dir sim test_results.txt]
}

close_sim