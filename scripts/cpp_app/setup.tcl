#!/usr/bin/env tclsh

proc print_usage {} {
    puts "Usage:"
    puts "  setup.tcl <hardware.xsa> <workspace> <source-dir> <include-dir>"
    exit 1
}

proc remove_generated_template_sources {application_source_directory} {
    if {![file isdirectory $application_source_directory]} {
        return
    }

    # app create defaults to the installed "Hello World" template. Remove
    # only its generated C/C++ sources before importing the real application.
    # Keep lscript.ld and all generated project metadata.
    foreach pattern [list *.c *.cc *.cpp *.cxx *.h *.hh *.hpp *.hxx] {
        foreach generated_file [glob -nocomplain \
                -directory $application_source_directory $pattern] {
            puts "Removing generated bootstrap file: $generated_file"
            file delete -force $generated_file
        }
    }
}

if {$argc != 4} {
    print_usage
}

set xsa_location [file normalize [lindex $argv 0]]
set workspace    [file normalize [lindex $argv 1]]
set source_path  [file normalize [lindex $argv 2]]
set include_path [file normalize [lindex $argv 3]]

set app_name      "sw"
set processor     "psu_cortexr5_0"
set build_config  "Debug"
set cpp_flags     {-std=c++11 -fno-exceptions -fno-rtti}

if {![file isfile $xsa_location]} {
    puts stderr "ERROR: XSA does not exist: $xsa_location"
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

set main_file [file join $source_path "main.cpp"]

if {![file isfile $main_file]} {
    puts stderr "ERROR: main.cpp does not exist:"
    puts stderr "  $main_file"
    exit 5
}

set main_handle [open $main_file r]
set main_content [read $main_handle]
close $main_handle

if {![regexp {\mmain\M[ \t\r\n]*\(} $main_content]} {
    puts stderr "ERROR: main.cpp does not define main():"
    puts stderr "  $main_file"
    exit 6
}

puts "Setup script:  [file normalize [info script]]"
puts "XSA:           $xsa_location"
puts "Workspace:     $workspace"
puts "Source path:   $source_path"
puts "Include path:  $include_path"
puts "Processor:     $processor"
puts "Language:      C++"
puts "C++ standard:  C++11"
puts "C++ flags:     $cpp_flags"

file mkdir $workspace
setws $workspace

# IMPORTANT:
# Do not pass -template here. Vitis then uses its installed default
# "Hello World" template, while -lang c++ selects the C++ application and
# linker toolchain. This avoids relying on a non-existent template such as
# a C++-specific empty template.
app create \
    -name $app_name \
    -hw $xsa_location \
    -proc $processor \
    -os standalone \
    -lang c++

set application_source_directory [file join $workspace $app_name "src"]
remove_generated_template_sources $application_source_directory

# Import the real C++ application sources into sw/src.
importsources \
    -name $app_name \
    -path $source_path

app config \
    -name $app_name \
    -set build-config $build_config

app config \
    -name $app_name \
    -add include-path \
    $include_path

app config \
    -name $app_name \
    -add compiler-misc \
    $cpp_flags

set imported_main [file join $application_source_directory "main.cpp"]

if {![file isfile $imported_main]} {
    puts stderr "ERROR: main.cpp was not imported:"
    puts stderr "  $imported_main"
    exit 7
}

puts ""
puts "Imported sources:"

foreach file_name [glob -nocomplain \
        -directory $application_source_directory *] {
    puts "  $file_name"
}

puts ""
puts "C++ workspace setup completed successfully."
puts "Run build.sh to generate the ELF."

exit 0
