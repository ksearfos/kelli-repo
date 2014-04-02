#!/bin/env ruby

RUN_IN_TEST_MODE = (ARGV[0] == '--test-mode')
record_comparer_runner = RecordComparerRunner.new(:lab, RUN_IN_TEST_MODE, 1100)
record_comparer_runner.run