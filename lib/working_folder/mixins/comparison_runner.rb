require 'working_folder/comparison_runner_class'
require 'working_folder/mixins/comparison_result'

module ComparisonRunner
  extend ComparisonResult
  
  def self.set_up(hl7_files, result_directory)
    @hl7_files = hl7_files
    @result_directory = result_directory
    @temp_file = "#{@result_directory}/temp_results"
  end
  
  def self.run
    $logger.info "Found #{@hl7_files.size} new file(s)\n"  
    until @hl7_files.empty?   # I am hoping that doing it this way will clear up memory as we go along
      infile = @hl7_files.shift
      outfile = "#{@result_directory}/#{File.basename(infile)}"
      compare_file(infile)
      compare_file_results(outfile)
    end # until  

    $logger.info "Exiting..."
    $logger.close
  end

  def self.compare_file(infile)
    runner = ComparisonRunnerObject.new(infile, @temp_file)
    runner.compare
    ComparisonResult.record_count += runner.record_count 
  end

  def self.compare_file_results(outfile)
    runner = ComparisonRunnerObject.new(@temp_file, outfile)
    runner.compare       
    remove_files([@temp_file]) 
  end

  def compare_result_files  
  end

  def compare_result_file_results
  end
end