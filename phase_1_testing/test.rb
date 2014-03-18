#!/bin/env ruby

$LOAD_PATH.unshift File.dirname __FILE__    # phase_1_testing directory
require 'lib/hl7module/HL7'

FILE = "C:/Users/Owner/Documents/manifest_rad_out.txt"

mh = HL7Test::MessageHandler.new FILE
puts mh.records.size
puts mh.first.segments.keys