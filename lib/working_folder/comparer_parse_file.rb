require 'working_folder/comparison_runner'

TIMESTAMP = Time.now.strftime "%H%M_%m-%d-%Y"      # HHMM_MM-DD-YYYY

def run_comparison(hl7_files, result_directory)
  result_file_prefix = "#{result_directory}/#{TIMESTAMP}" 
  my_results = Hash.new(0)  

  $logger.info "Found #{hl7_files.size} new file(s)\n"  
  until hl7_files.empty?   # I am hoping that doing it this way will clear up memory as we go along
    file = hl7_files.shift
    outfile = result_directory + "/" + File.basename(file)
    tmp = result_file_prefix + "temp_results"
    
    runner = ComparisonRunner.new(file, tmp)
    runner.compare            
    my_results[:number_of_records] += runner.record_count
      
    runner = ComparisonRunner.new(tmp, outfile)      
    criteria, subset = runner.compare
    my_results[:matched_criteria] = criteria
    my_results[:subset_size] = subset   
    remove_files( [tmp] )  
  end # until  

  $logger.info "Exiting..."
  $logger.close
  my_results  # NEW
end