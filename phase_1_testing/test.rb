require "#{__FILE__}\\..\\hl7_utils.rb"
require './HL7ProcsMod.rb'

# require all utility files, stored in [HEAD]/utilities
DEL = "\\"       # windows-style file path delimiter
pts = __FILE__.split( '/' )
pts.pop(2)
util_path = pts.join( DEL ) + DEL + 'utilities' 
util = Dir.new( util_path )   # all helper functions
util.entries.each{ |f| require util_path + DEL + f if f.include?( '.rb' ) }

# FILE = "C:/Users/Owner/Documents/manifest_lab_out.txt"
# FILE = "C:/Users/Owner/Documents/manifest_lab_short_unix.txt"
FILE = "C:/Users/Owner/Documents/testing_data.txt"
msg = get_hl7( FILE )
# all_hl7 = hl7_by_record( msg )
rec = HL7::Message.new( msg )

puts HL7Procs::REASON.call(rec)
puts HL7Procs::RES_INT.call(rec)
puts HL7Procs::RES_ST.call(rec)
puts HL7Procs::EXAM_DT.call(rec)

=begin

  ORD_MD = Proc.new{ |rec| has_val?(rec,"obr16") }
  RES_DT = Proc.new{ |rec| has_val?(rec,"obr22") }
  RES_ST = Proc.new{ |rec| has_val?(rec,"obr25") } 
  EXAM_DT = Proc.new{ |rec| has_val?(rec,"obr27") } 
  REASON = Proc.new{ |rec| has_val?(rec,"obr31") }
  RES_INT = Proc.new{ |rec| has_val?(rec,"obr32") }
=end