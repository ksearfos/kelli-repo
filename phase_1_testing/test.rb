#!/bin/env ruby

$LOAD_PATH.unshift File.dirname __FILE__    # phase_1_testing directory
require 'lib/hl7module/HL7'

FILE = "C:/Users/Owner/Documents/enc_post.dat"

mh = HL7Test::MessageHandler.new FILE
mh.each{ |r|
  r[:PID].view
  r[:PV1].view
  puts ""
}
