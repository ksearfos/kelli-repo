require 'working_folder/comparison_runner'

TIMESTAMP = Time.now.strftime "%H%M_%m-%d-%Y"      # HHMM_MM-DD-YYYY

def run_comparison(hl7_files, result_directory)
  result_file_prefix = "#{result_directory}/#{TIMESTAMP}" 
  my_results = Hash.new(0)  #{ :number_of_records => 0, :matched_criteria => 0, :subset_size => 0 }
  num_records = 0

  $logger.info "Found #{hl7_files.size} new file(s)\n"  
  until hl7_files.empty?   # I am hoping that doing it this way will clear up memory as we go along
    file = hl7_files.shift
    outfile = result_directory + "/" + File.basename(file)
    tmp = result_file_prefix + "temp_results"
    
    runner = ComparisonRunner.new(file, tmp)
    runner.compare
    # file_handler = nil    # reset
#     
    # file_handler = get_records(file, MAX_RECS)   
    # if file_handler.nil?   # will be nil if file was empty
      # remove_files( [file] )   # remove even if we are testing! it's empty!!
    # else        
      # begin
        # $logger.info "Found #{file_handler.size} record(s)\n" 
        # $logger.info "Comparing records..."    
        # num_records += file_handler.records.size  #NEW
        # run_record_comparer( tmp, file_handler.records, false, false )
        # file_handler.next     # get the next however-many records -- @records will be empty if we got them all
      # end until file_handler.records.empty?
            
      my_results[:number_of_records] += runner.record_count
      
      runner = ComparisonRunner.new(tmp, outfile)      
      
      # $logger.info "Found #{tmp_file_handler.size} record(s)\n" 
      # $logger.info "Comparing records..."       
      # criteria, subset = run_record_comparer( outfile, tmp_file_handler.records, false, true )
      criteria, subset = runner.compare
      my_results[:matched_criteria] = criteria  # NEW
      my_results[:subset_size] = subset   # NEW
      remove_files( [tmp] )  
    # end
  end # until  

  $logger.info "Exiting..."
  $logger.close
  my_results  # NEW
end