# require 'working_folder/mixins/comparison_runner'
# require 'working_folder/mixins/loggable'
require 'working_folder/subset_finder'

# include Loggable

def run(type, input_directory)
  finder = SubsetFinder.new(type, input_directory)
  finder.run
  # ComparisonResult.reset
  # make_logger(input_directory)
  # @logger.info "Checking #{input_directory} for files..."
  # files = get_files(input_directory, /^#{type}_\w+/) 
  # ComparisonRunner.set_up(files, "#{input_directory}/results")
  # ComparisonRunner.run_comparison  # returns result hash
end
=begin
def get_files(directory, pattern)
  hl7_files = []
  
  # find files, store in hl7_files with full pathname
  Dir.entries(directory).select do |filename|
    fullname = "#{directory}/#{filename}"
    hl7_files << fullname if File.file?(fullname) && filename =~ pattern
  end
  
  hl7_files
end
=end