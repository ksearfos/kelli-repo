#!/bin/env ruby

$LOAD_PATH.unshift File.dirname __FILE__    # phase_1_testing directory
require 'lib/extended_base_classes'
require 'lib/hl7/HL7'
require 'classes/CustomizedLogger'
INFILE = "C:/Users/Owner/Documents/script_input/manifest_rad201404021205.txt"

array = [1,2,3,4]
puts array.remove(3) * ','
puts array * ','
