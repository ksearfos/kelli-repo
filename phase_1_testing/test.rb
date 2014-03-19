#!/bin/env ruby

$LOAD_PATH.unshift File.dirname __FILE__    # phase_1_testing directory
require 'lib/hl7module/HL7'

FILE = "C:/Users/Owner/Documents/manifest_lab_out.txt"

mh = HL7Test::MessageHandler.new FILE
ct = 0
mh.each{ |rec| ct += 1 if rec[:OBR].size > 1 }
puts ct