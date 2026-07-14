#!/usr/bin/env tclsh

if {$argc != 1} {
    puts "Usage: build.tcl <workspace>"
    exit 1
}

set workspace    [file normalize [lindex $argv 0]]
set app_name     "sw"
set build_config "Debug"

if {![file isdirectory $workspace]} {
    puts stderr "ERROR: Workspace does not exist: $workspace"
    exit 2
}

set app_directory [file join $workspace $app_name]
set source_main   [file join $app_directory "src" "main.cpp"]
set build_dir     [file join $app_directory $build_config]
set elf_path      [file join $build_dir "${app_name}.elf"]

if {![file isfile $source_main]} {
    puts stderr "ERROR: Application main.cpp does not exist:"
    puts stderr "  $source_main"
    exit 3
}

setws $workspace

app config \
    -name $app_name \
    -set build-config $build_config

# Force Vitis managed build files and C++ object lists to be regenerated.
if {[file exists $build_dir]} {
    puts "Removing stale build directory: $build_dir"
    file delete -force $build_dir
}

puts "Building C++ application: $app_name"

app build -name $app_name

if {![file isfile $elf_path]} {
    puts stderr ""
    puts stderr "ERROR: ELF was not generated:"
    puts stderr "  $elf_path"
    exit 4
}

puts ""
puts "C++ build completed successfully."
puts "ELF:"
puts "  $elf_path"

exit 0
