require 'working_folder/comparison_runner_class'
require 'working_folder/mixins/comparison_result'
require 'working_folder/mixins/hl7_file_reader'

module ComparisonRunner
  include HL7FileReader
  extend ComparisonResult
  
  def set_up_comparison_runner #(type, directory)  #(hl7_files, result_directory)
    # specify_hl7_file_requirements(directory, type)
    # @hl7_files = hl7_files
    @result_directory = "#{@hl7_directory}/results"
    @temp_file = "#{@result_directory}/temp_results"
  end
  
  def run_comparison
    $logger.info "Found #{@hl7_files.size} new file(s)"  
    until @hl7_files.empty?   # I am hoping that doing it this way will clear up memory as we go along
      infile = @hl7_files.shift
      outfile = "#{@result_directory}/#{File.basename(infile)}"
      compare_file(infile)
      compare_file_results(outfile)
    end # until  

    $logger.info "Exiting..."
    $logger.close
  end

  def compare_file(infile)
    runner = ComparisonRunnerObject.new(infile, @temp_file)
    runner.compare
    ComparisonResult.record_count += runner.record_count 
  end

  def compare_file_results(outfile)
    runner = ComparisonRunnerObject.new(@temp_file, outfile)
    runner.compare       
    remove_files([@temp_file]) 
  end

  def compare_result_files  
  end

  def compare_result_file_results
  end
end