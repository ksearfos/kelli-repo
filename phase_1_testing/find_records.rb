# last updated 2/28/14 3:23pm

require "#{__FILE__}\\..\\hl7_utils.rb"
require "#{__FILE__}\\..\\RecordComparer.rb"

# require all utility files, stored in [HEAD]/utilities
DEL = "\\"       # windows-style file path delimiter
pts = __FILE__.split( '/' )
pts.pop(2)
util_path = pts.join( DEL ) + DEL + 'utilities' 
util = Dir.new( util_path )   # all helper functions
util.entries.each{ |f| require util_path + DEL + f if f.include?( '.rb' ) }

# FILE = "C:/Users/Owner/Documents/manifest_lab_out.txt"
FILE = "C:/Users/Owner/Documents/manifest_lab_short_unix.txt"
OUT_FILE = "C:/Users/Owner/Documents/test_results.txt"

msg = get_hl7( FILE )
all_hl7 = hl7_by_record( msg )
pos_comparer = RecordComparer.new( all_hl7 )           # finds all positive test cases
neg_comparer = RecordComparer.new( all_hl7, false )    # finds all negative test cases, e.g. cases where criterion are not met
pos_comparer.analyze
neg_comparer.analyze

res = pos_comparer.people_to_use
res << neg_comparer.people_to_use
res.flatten!.uniq!        # some records might both pass criteria and fail them, so get rid of duplicates

write_str = ""
res.map!{ |pt|
  pt = "Patient ID: " + pt[:ID] + "\nPatient Name: " + pt[:NAME] + "\nVisit Number: " + pt[:VISIT] + "\n" 
}
write_str = res.join( "\n" )

File.open( OUT_FILE, "w" ) { |f| f.puts write_str }

puts "\nResults can be found in #{OUT_FILE}."