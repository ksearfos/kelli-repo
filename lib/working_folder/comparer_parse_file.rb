require 'working_folder/comparison_runner'
require 'working_folder/mixins/comparison_result'

def run_comparison(hl7_files, result_directory)
  result_file_prefix = "#{result_directory}/" 

  $logger.info "Found #{hl7_files.size} new file(s)\n"  
  until hl7_files.empty?   # I am hoping that doing it this way will clear up memory as we go along
    file = hl7_files.shift
    outfile = result_directory + "/" + File.basename(file)
    tmp = result_file_prefix + "temp_results"
    
    runner = ComparisonRunner.new(file, tmp)
    runner.compare
    ComparisonResult.record_count += runner.record_count        
      
    runner = ComparisonRunner.new(tmp, outfile)
    runner.compare       
    remove_files( [tmp] )  
  end # until  

  $logger.info "Exiting..."
  $logger.close
  ComparisonResult.to_hash
end