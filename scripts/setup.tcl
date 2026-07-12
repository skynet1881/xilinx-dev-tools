#!/usr/bin/env tclsh

proc print_usage {} {
    puts "Usage:"
    puts "  setup.tcl <hardware.xsa> <workspace> <source-dir> <include-dir>"
    exit 1
}

if {$argc != 4} {
    print_usage
}

set xsa_location [file normalize [lindex $argv 0]]
set workspace    [file normalize [lindex $argv 1]]
set source_path  [file normalize [lindex $argv 2]]
set include_path [file normalize [lindex $argv 3]]

if {![file isfile $xsa_location]} {
    puts stderr "ERROR: XSA file does not exist: $xsa_location"
    exit 2
}

if {![file isdirectory $source_path]} {
    puts stderr "ERROR: Source directory does not exist: $source_path"
    exit 3
}

if {![file isdirectory $include_path]} {
    puts stderr "ERROR: Include directory does not exist: $include_path"
    exit 4
}

puts "XSA:          $xsa_location"
puts "Workspace:    $workspace"
puts "Source path:  $source_path"
puts "Include path: $include_path"

file mkdir $workspace
setws $workspace

platform create \
    -no-boot-bsp \
    -name zcu104_platform \
    -hw $xsa_location

platform active zcu104_platform

domain create \
    -name app_domain \
    -os standalone \
    -proc psu_cortexr5_0

app create \
    -name sw \
    -platform zcu104_platform \
    -domain app_domain \
    -template "Empty Application(C)"

# Import or link all C/C++ source files.
importsources \
    -name sw \
    -path $source_path \
    -soft-link

# Add the application's header directory.
app config \
    -name sw \
    -add include-path \
    $include_path

puts "Workspace setup completed successfully."
puts "Run the build script to build application: sw"

exit 0