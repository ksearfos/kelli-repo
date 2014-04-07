#!/bin/env ruby

RUN_IN_TEST_MODE = (ARGV[0] == '--test-mode')
test_runner = AutomatedTestRunner.new(:enc, RUN_IN_TEST_MODE)
test_runner.run
record_comparer_runner.shutdown