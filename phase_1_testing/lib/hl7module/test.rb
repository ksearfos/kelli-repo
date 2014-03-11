#!/bin/env ruby

proj_dir = File.expand_path( "../..", __FILE__ )
require "#{proj_dir}/lib/extended_base_classes.rb"
require "#{proj_dir}/hl7module/HL7.rb"

FILE = "#{proj_dir}/resources/manifest_lab_short_unix.txt"
# FILE = "C:/Users/Owner/Documents/manifest_lab_out_shortened.txt"
# FILE = "C:/Users/Owner/Documents/manifest_rad_out_shortened.txt"

msg = <<END
ORC|RE
OBX|1|NM|WBC^WBC^LA01|1|9.46|K/mcL|4.50-11.00||||F
OBX|2|NM|RBC^RBC^LA01|1|3.71|M/mcL|4.50-5.90|L|||F
END

include HL7Test

mh = MessageHandler.new( FILE )
rec = mh.records[0]
rec.view_segments
nte = rec[:NTE]
nte.view
