#!/bin/env ruby

$LOAD_PATH.unshift File.dirname __FILE__    # phase_1_testing directory
require 'lib/HL7CSV'

FILE = "C:/Users/Owner/Documents/script_input/enc_post.dat"
OUTFILE = $LOAD_PATH.first + "/testcsv.csv"

mh = HL7Test::MessageHandler.new( FILE )
HL7CSV.record_to_spreadsheet( OUTFILE, mh.records )
