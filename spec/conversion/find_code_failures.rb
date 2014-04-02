#!/bin/env ruby

results_directory = ARGV[0]
all_results_files = Dir.entries(results_directory).select{ |file| file.include?( "rspec.log" ) }
puts "Found #{all_results_files.size} files.\n\n"

all_results_files.map!{ |filename| results_directory + "/" + filename }
all_results_files.each{ |file|
  file_text = open(file).read  
  lines = file_text.split( "\n" )
  blank_line_indexes = []
  for i in 0...lines.size
    blank_line_indexes << i if lines[i] !~ /\S/    # all whitespace
  end

  paragraphs = []
  begin
    start = blank_line_indexes.shift
    finish = blank_line_indexes.first   # this will be start next iteration, so don't remove it yet!
    break if finish.nil?
    
    paragraphs << lines[start+1...finish] * "\n"
  end until blank_line_indexes.empty?
  paragraphs.uniq!
  paragraphs.delete_if{ |paragraph| paragraph.strip !~ /^\d+\) / }   # doesn't begin 'N) '
  paragraphs.delete_if{ |paragraph| paragraph.include?( "Failure/Error: @failed.should be_empty" ) }
  paragraphs.each{ |paragraph| puts paragraph + "\n" }
  puts "\n"
}

puts "\nFinished."
