#!/bin/env ruby

$LOAD_PATH.unshift File.dirname __FILE__    # phase_1_testing directory
require 'lib/hl7module/HL7'

FILE = "C:/Users/Owner/Documents/manifest_lab_out.txt"

mh = HL7Test::MessageHandler.new FILE
puts HL7Test.get_data( mh.records, "obr4" ).size
