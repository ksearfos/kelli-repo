proj_dir = File.expand_path("../../",__FILE__)
require "#{proj_dir}/Record_Comparer/RecordComparer.rb"

input_path = "C:/Users/Owner/Documents"
TYPE = :lab
FILE = "#{input_path}/manifest_#{TYPE}_out.txt"
OUT_FILE = "#{proj_dir}/Record_Comparer/#{TYPE}_record_results.txt"
VERBOSE = false

mh = HL7Test::MessageHandler.new( FILE )
recs = mh.records.clone
comparer = RecordComparer.new( recs, TYPE )
comparer.analyze
puts comparer.summary

if VERBOSE
  puts "\nThe unmatched criteria are:"
  puts comparer.unmatched
end

puts "\nSaving results..."

File.open( OUT_FILE, "w" ) { |f| f.puts comparer.used_records }

puts "\nResults can now be found in #{OUT_FILE}."