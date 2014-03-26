#!/bin/env ruby

$LOAD_PATH.unshift File.dirname __FILE__    # phase_1_testing directory
require 'lib/hl7module/HL7'

name = %w( Eckert Daniel J III)
puts HL7Test.is_name?(name)
