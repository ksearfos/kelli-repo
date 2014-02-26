require "#{__FILE__}\\..\\hl7_utils.rb"

# require all utility files, stored in [HEAD]/utilities
DEL = "\\"       # windows-style file path delimiter
pts = __FILE__.split( '/' )
pts.pop(2)
util_path = pts.join( DEL ) + DEL + 'utilities' 
util = Dir.new( util_path )   # all helper functions
util.entries.each{ |f| require util_path + DEL + f if f.include?( '.rb' ) }

FILE = "C:/Users/Owner/Documents/manifest_lab_out.txt"
# FILE = "C:/Users/Owner/Documents/manifest_lab_short_unix.txt"
msg = get_hl7( FILE )
all_hl7 = hl7_by_record( msg )

puts "Looking through records..."

types = []
# find all different PV1.18 values (patient types)
all_hl7.each{ |rec|
  segs = rec[:PID]
  next unless segs
  
  has_e1 = false
  segs.each{ |pid| has_e1 = true if !pid.e1.empty? }
  puts record_details( rec ) if has_e1
}

puts "Completed."
