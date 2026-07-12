#!/usr/bin/env tclsh

if {$argc != 1} {
    puts "Usage: build.tcl <workspace>"
    exit 1
}

set workspace [file normalize [lindex $argv 0]]

if {![file exists $workspace]} {
    puts stderr "ERROR: Workspace does not exist: $workspace"
    exit 2
}

setws $workspace

puts "Building application: sw"

app build -name sw

puts "Build completed successfully."

exit 0