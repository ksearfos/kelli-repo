# last updated 2/28/14 3:23pm

require "./RecordComparer.rb"

# require all utility files, stored in phase_1_testing/lib
$proj_dir = File.expand_path( "..", __FILE__ )    # phase_1_testing directory
util_path = $proj_dir + "/lib"
input_path = $proj_dir + "/resources"

require "#{util_path}/extended_base_classes.rb"

# FILE = "#{input_path}/manifest_lab_out.txt"
FILE = "#{input_path}/manifest_lab_short_unix.txt"
OUT_FILE = "#{$proj_dir}/record_results.txt"
VERBOSE = true

mh = HL7Test::MessageHandler.new( FILE )
recs = mh.records.clone

pos_comparer = RecordComparer.new( recs )           # finds all positive test cases
neg_comparer = RecordComparer.new( recs, false )    # finds all negative test cases, e.g. cases where criterion are not met
pos_comparer.analyze
neg_comparer.analyze
pos_comparer.summarize( VERBOSE )
neg_comparer.summarize( VERBOSE )

puts "\nSaving results..."
sleep 1

res = pos_comparer.people_to_use
res << neg_comparer.people_to_use
res.flatten!.uniq!        # some records might both pass criteria and fail them, so get rid of duplicates

write_str = ""
res.map!{ |pt|
  pt = "Patient ID: " + pt[:ID] + "\nPatient Name: " + pt[:NAME] + "\nVisit Number: " + pt[:VISIT] + "\n" 
}
write_str = res.join( "\n" )

File.open( OUT_FILE, "w" ) { |f| f.puts write_str }

puts "Results can now be found in #{OUT_FILE}."