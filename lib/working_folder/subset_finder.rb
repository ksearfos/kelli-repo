require 'working_folder/mixins/comparison_runner'
require 'working_folder/mixins/loggable'

class SubsetFinder
  include Loggable, ComparisonRunner

  def initialize(type, directory)
    # set_up_comparison_runner(type, directory)  #("#{@hl7_directory}/results")
    # @message_type = type
    # @input_directory = directory
    specify_hl7_file_requirements(directory, type)
    make_logger(@hl7_directory)   # adds @logger
    ComparisonResult.reset
    $logger = @logger
  end
  
  def run
    read_in_files
    set_up_comparison_runner  #("#{@hl7_directory}/results")
    run_comparison
  end

  def result
    ComparisonResult.to_hash
  end

  private
  
  # def read_in_files
    # log "Checking #{@input_directory} for files..."
    # @hl7_files = Dir.entries(@input_directory).select { |file| is_correct_type?(file) } 
    # @hl7_files.map! { |filename| File.join(@input_directory, filename) }
  # end
#   
  # def is_correct_type?(filename)
    # fullname = "#{@input_directory}/#{filename}"
    # File.file?(fullname) && filename =~ /^#{@message_type}_\w+/
  # end
end