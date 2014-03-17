#!/bin/env ruby

$LOAD_PATH.unshift File.dirname __FILE__    # phase_1_testing directory
require 'lib/hl7module/HL7'

FILE = "C:/Users/Owner/Documents/manifest_rad_out.txt"
FIELD = "pv118"

mh = HL7Test::MessageHandler.new( FILE )
data = []

mh.records.each{ |msg| data << msg.fetch_field(FIELD) }
data.flatten!(1)
data.map!{ |field| field.to_s }
data.uniq!

puts data.join( ", " )
