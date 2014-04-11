#!/bin/env ruby

$LOAD_PATH.unshift(File.expand_path("../..", __FILE__))
require 'Classes/AutomatedTestsRunner'
require 'trollop'   # command-line argument parsing

# set up the defaults
RECORD_TYPES = { 'enc'=>:enc, 'lab'=>:lab, 'rad'=>:rad, 'encounters'=>:enc, 'labs'=>:lab, 'adt'=>:enc }

# define command-line options
opts = Trollop::options do
  banner <<-EOB
  This script runs rspec automated tests on all records of type specified.
  By default, keeps a copy of all files evaluated.  To change this, use --no-test-mode.
  
  Options:
  EOB
  
  opt :test_mode, "Run in test mode", :default => true
  opt :record_type, "Record type", :type => :string             # options: enc, lab, rad
end

# define errors with command-line arguments
rec_type = opts[:record_type]

Trollop::die :record_type, "is required" unless opts[:record_type_given]
Trollop::die :record_type, "unknown type '#{rec_type}'" unless RECORD_TYPES.has_key?(rec_type)

# the actual "script" portion
test_runner = AutomatedTestsRunner.new(RECORD_TYPES[rec_type], opts[:test_mode])
test_runner.run
test_runner.shutdown