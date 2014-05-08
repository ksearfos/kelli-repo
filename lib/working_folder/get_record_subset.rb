require 'working_folder/comparer_parse_file'
# require 'working_folder/mixins/comparison_result'

include ComparisonRunner

TIMESTAMP = Time.now.strftime "%H%M_%m-%d-%Y"      # HHMM_MM-DD-YYYY

def run(type, input_directory)
  ComparisonResult.reset
  make_logger(input_directory)
  
  $logger.info "Checking #{input_directory} for files..."
  files = get_files(input_directory, /^#{type}_\w+/)
  
  run_comparison(files, "#{input_directory}/results")  # returns result hash
end

def make_logger(input_directory)
  log_directory = "#{input_directory}/logs"
  log_file = "#{log_directory}/#{TIMESTAMP}_comparer_parse_file.log"
  
  # create the directory, if needed
  `mkdir "#{log_directory}"` unless File.directory?(log_directory) 
  
  # create the logger
  $logger = set_up_logger(log_file) 
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