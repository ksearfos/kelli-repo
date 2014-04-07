#!/bin/env ruby

size_string = ARGV[0].match(/--size=(\d+)/)
raise ArgumentError, "Specify number of messages with --size=" if size_string.nil?

record_comparer_runner = RecordComparerRunner.new(:enc, false, size_string[1])
record_comparer_runner.supplement_existing
record_comparer_runner.shutdown