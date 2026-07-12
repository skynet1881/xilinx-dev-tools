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

set platform_name "zcu104_platform"
set domain_name   "app_domain"
set app_name      "sw"
set processor     "psu_cortexr5_0"

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

set main_file [file join $source_path "main.c"]

if {![file isfile $main_file]} {
    puts stderr "ERROR: main.c does not exist:"
    puts stderr "  $main_file"
    exit 5
}

set main_handle [open $main_file r]
set main_content [read $main_handle]
close $main_handle

if {![regexp {\mmain\M[ \t\r\n]*\(} $main_content]} {
    puts stderr "ERROR: main.c does not define main():"
    puts stderr "  $main_file"
    exit 6
}

puts "XSA:          $xsa_location"
puts "Workspace:    $workspace"
puts "Source path:  $source_path"
puts "Include path: $include_path"
puts "Processor:    $processor"

file mkdir $workspace
setws $workspace

platform create \
    -no-boot-bsp \
    -name $platform_name \
    -hw $xsa_location

platform active $platform_name

domain create \
    -name $domain_name \
    -os standalone \
    -proc $processor

platform generate

app create \
    -name $app_name \
    -platform $platform_name \
    -domain $domain_name \
    -template {Empty Application(C)}

# Import the complete source directory into sw/src.
# Do not use file copy and do not delete template files manually.
importsources \
    -name $app_name \
    -path $source_path

app config \
    -name $app_name \
    -add include-path \
    $include_path

app config \
    -name $app_name \
    -set build-config Debug

set imported_main [file join $workspace $app_name "src" "main.c"]

if {![file isfile $imported_main]} {
    puts stderr "ERROR: main.c was not imported:"
    puts stderr "  $imported_main"
    exit 7
}

puts ""
puts "Imported sources:"

foreach file_name [glob -nocomplain \
        -directory [file join $workspace $app_name "src"] *] {
    puts "  $file_name"
}

puts ""
puts "Workspace setup completed successfully."

exit 0