#!/bin/env ruby

require 'trollop'   # command-line argument parsing

# set up the few defaults
RECORD_TYPES = { 'enc'=>:enc, 'lab'=>:lab, 'rad'=>:rad, 'encounters'=>:enc, 'labs'=>:lab, 'adt'=>:enc }
DEFAULT_SIZES = { enc: 400, lab: 1100, rad: 1000 }

# define command-line options
opts = Trollop::options do
  banner <<-EOB
  This script finds a sample set of patient records to use in manual validation.
  By default, keeps a copy of all files evaluated.  To change this, use --no-test-mode.
  Can run full record evaluation, or find a supplemental set of random records.
  
  Options:
  EOB
  
  opt :test_mode, "Run in test mode", :default => true
  opt :record_type, "Record type", :type => :string             # options: enc, lab, rad
  opt :supplement, "Supplement existing record set", :type => :int
  opt :ignore, "File containing records to exclude from results", :type => :string
end

# define errors with command-line arguments
rec_type = opts[:record_type]
ignore_file = opts[:ignore]

Trollop::die :record_type, "is required" unless opts[:record_type_given]
Trollop::die :record_type, "unknown type '#{rec_type}'" unless RECORD_TYPES.has_key?(rec_type)
Trollop::die :ignore, "cannot find file: #{ignore_file}" unless ignore_file.nil? || File.exists?(ignore_file)

# other variables
type = RECORD_TYPES[rec_type]
size = opts[:supplement_given] ? opts[:supplement] : DEFAULT_SIZES[type]
runmode = opts[:supplement_given] ? :supplement_existing : :run

# the actual "script" portion
record_comparer_runner = RecordComparerRunner.new(type, opts[:test_mode], size)
record_comparer_runner.exclude_records_in_file(ignore_file) if ignore_file
record_comparer_runner.send(runmode)
record_comparer_runner.shutdown