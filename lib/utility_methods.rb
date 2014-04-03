  # determines the number of files in given directory     
  def directory_size(directory)
    Dir.entries(directory).size
  end

  # redirects standard output to write to the given file
  def redirect_stdout(file)
    $stdout.reopen(file)  
  end
  
  def get_paths_of_files_in_directory(directory, filename_pattern = /.*/)
    file_list = [] 
    Dir.entries(directory).each do |filename|
      full_filepath = "#{directory}/#{filename}"
      file_list << full_filepath if File.file?(full_filepath) && filename.match(filename_pattern)
    end
    file_list
  end