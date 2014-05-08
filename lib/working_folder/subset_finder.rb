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
    # ComparisonResult.reset
    # make_logger(input_directory)
  log "Checking #{@input_directory} for files..."
  files = get_files(@input_directory, /^#{@message_type}_\w+/) 
  ComparisonRunner.set_up(files, "#{@input_directory}/results")
  ComparisonRunner.run_comparison  # returns result hash
end

def get_files(directory, pattern)
  hl7_files = []
  
  # find files, store in hl7_files with full pathname
  Dir.entries(directory).select do |filename|
    fullname = "#{directory}/#{filename}"
    hl7_files << fullname if File.file?(fullname) && filename =~ pattern
  end
  
  hl7_files
end
end