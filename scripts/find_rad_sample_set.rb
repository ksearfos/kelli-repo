#!/bin/env ruby

RUN_IN_TEST_MODE = (ARGV[0] == '--test-mode')
record_comparer_runner = RecordComparerRunner.new(:rad, RUN_IN_TEST_MODE, 1000)
record_comparer_runner.run