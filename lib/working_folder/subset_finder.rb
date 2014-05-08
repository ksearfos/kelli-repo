require 'working_folder/mixins/comparison_runner'
require 'working_folder/mixins/loggable'

class SubsetFinder
  include Loggable, ComparisonRunner

  def initialize(type, directory)
    @message_type = type
    @input_directory = directory
    make_logger(@input_directory)   # adds @logger
    ComparisonResult.reset
    $logger = @logger
  end
  
  def run
    # log "Checking #{@input_directory} for files..."
    # files = get_input_files  #(@input_directory, /^#{@message_type}_\w+/) 
    ComparisonRunner.set_up(input_files, "#{@input_directory}/results")
    ComparisonRunner.run
  end

  def result
    ComparisonResult.to_hash
  end

  private
  
  def input_files #(directory, pattern)
    log "Checking #{@input_directory} for files..."
    # hl7_files = []
  
    # find files, store in hl7_files with full pathname
    hl7_files = Dir.entries(@input_directory).select { |file| is_correct_type?(file) } 
      # fullname = "#{@input_directory}/#{filename}"
      # hl7_files << fullname if File.file?(fullname) && filename.include?(@message_type)
    # end
  
    hl7_files.map { |filename| File.join(@input_directory, filename) }
  end
  
  def is_correct_type?(filename)
    fullname = "#{@input_directory}/#{filename}"
    File.file?(fullname) && filename =~ /^#{@message_type}_\w+/
  end
end