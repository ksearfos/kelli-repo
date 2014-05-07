require_relative 'comparer_parse_file'

def run(type, input_directory)
  input_file_pattern = /^#{type}_\w+/
  run_comparison(input_directory, input_file_pattern)
end