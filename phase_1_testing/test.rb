#!/bin/env ruby

$LOAD_PATH.unshift File.dirname __FILE__    # phase_1_testing directory
require 'lib/hl7module/HL7'
require 'libHL7CSV'

infile = "C:/Users/Owner/Documents/script_input/enc_pre_really_big.dat"
outfile = "C:/Users/Owner/Documents/supplemental_enc_records.csv"
 
handler = HL7::FileHandler.new( infile, 300 )
HL7CSV.records_to_spreadsheet( outfile, handler.records )
