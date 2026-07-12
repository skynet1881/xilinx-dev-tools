#!/usr/bin/env tclsh

proc print_usage {} {
    puts "Usage: setup.tcl <hardware.xsa> <workspace>"
    exit 1
}

if {$argc != 2} {
    print_usage
}

set xsa_location [file normalize [lindex $argv 0]]
set workspace    [file normalize [lindex $argv 1]]

set script_path [file dirname [file normalize [info script]]]

if {![file exists $xsa_location]} {
    puts stderr "ERROR: XSA file does not exist: $xsa_location"
    exit 2
}

puts "XSA:       $xsa_location"
puts "Workspace: $workspace"

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
    -template "Hello World"


puts "Workspace setup completed successfully."
puts "Run the build script to build application: sw"

exit 0