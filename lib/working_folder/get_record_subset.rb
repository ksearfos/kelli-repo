require_relative 'comparer_parse_file'

def run(type, input_directory)
  make_logger(input_directory)
  
  $logger.info "Checking #{input_directory} for files..."
  files = get_files(input_directory, /^#{type}_\w+/)
  
  run_comparison(files, "#{input_directory}/results")
end

def make_logger(input_directory)
  log_directory = "#{input_directory}/logs"
  log_file = "#{log_directory}/comparer_parse_file.log"
  
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