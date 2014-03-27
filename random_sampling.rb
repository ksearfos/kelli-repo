#!/bin/env ruby

$LOAD_PATH.unshift File.dirname __FILE__    # phase_1_testing directory
require 'lib/HL7CSV'

BASE_DIR = "C:/Users/Owner/Documents"
INFILE = "#{BASE_DIR}/script_input/enc_pre_really_big.dat"
OUTFILE = "#{BASE_DIR}/supplemental_enc_records.csv"
SIZE = 300
 
handler = HL7::FileHandler.new( INFILE, SIZE )
HL7CSV.records_to_spreadsheet( OUTFILE, handler.records )
