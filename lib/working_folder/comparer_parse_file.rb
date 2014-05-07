require 'working_folder/test_runner_helper'

TIMESTAMP = Time.now.strftime "%H%M_%m-%d-%Y"      # HHMM_MM-DD-YYYY
MAX_RECS = 1000

def run_comparison(input_directory, input_file_pattern)
  log_directory = "#{input_directory}/logs"
  log_file = "#{log_directory}/comparer_parse_file.log"
  result_file_prefix = "#{log_directory}/#{TIMESTAMP}" 
  my_results = { :number_of_records => 0, :matched_criteria => 0, :subset_size => 0 }
  num_records = 0
    
  # create the directory, if needed
  `mkdir "#{log_directory}"` unless File.directory?(log_directory)

  # set up - create logger and read in records from files
  $logger = set_up_logger(log_file)
  $logger.info "Checking #{input_directory} for files..."
  # find files, store in hl7_files with full pathname
  hl7_files = Dir.entries(input_directory).select do |f|
    File.file?("#{input_directory}/#{f}") && f =~ input_file_pattern
  end

  # if hl7_files.empty?
    # $logger.info "No new files found.\n"
  # else
  $logger.info "Found #{hl7_files.size} new file(s)\n"
  
  until hl7_files.empty?   # I am hoping that doing it this way will clear up memory as we go along
    fname = hl7_files.shift
    file = "#{input_directory}/#{fname}"
    outfile = log_directory + "/results_#{fname}"
    tmp = result_file_prefix + "temp_results"
    file_handler = nil    # reset
    
    file_handler = get_records( file, MAX_RECS )   
    if file_handler.nil?   # will be nil if file was empty
      remove_files( [file] )   # remove even if we are testing! it's empty!!
    else        
      begin
        $logger.info "Found #{file_handler.size} record(s)\n" 
        $logger.info "Comparing records..."    
        num_records += file_handler.records.size  #NEW
        run_record_comparer( tmp, file_handler.records, false, false )
        file_handler.next     # get the next however-many records -- @records will be empty if we got them all
      end until file_handler.records.empty?
            
      my_results[:number_of_records] = num_records
      tmp_file_handler = get_records( tmp )      
      
      $logger.info "Found #{tmp_file_handler.size} record(s)\n" 
      $logger.info "Comparing records..."       
      criteria, subset = run_record_comparer( outfile, tmp_file_handler.records, false, true )
      my_results[:matched_criteria] += criteria  # NEW
      my_results[:subset_size] += subset   # NEW
      remove_files( [tmp] )  
    end
  end # until  

  $logger.info "Exiting..."
  $logger.close
  my_results  # NEW
end