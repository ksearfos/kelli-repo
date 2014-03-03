#!/bin/env ruby

# a way to run rspec from in here, rather than through the command line
# currently opens a command prompt window while running... I am working on avoiding that

require 'Time'

TEST_DIR = File.expand_path( "../lab", __FILE__ )
FNAME = "lab"
TEST_FILE = TEST_DIR + "/" + FNAME + "_spec.rb"
TIME = Time.now.strftime( "%H%M_%m-%d-%Y" )   # HH-NN_Mmm-DD-YYYY
RESULTS_FILE = TEST_DIR + "/" + "#{TIME}_#{FNAME}_results.txt"

`rspec #{TEST_FILE} > #{RESULTS_FILE}`