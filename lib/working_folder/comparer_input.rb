class ComparerInput
  attr_reader :directory, :files
  
  def initialize(directory, file_pattern)
    @directory = directory
    @file_pattern = file_pattern
    find_files   # sets @files
  end
  
  def each_file(&block)
    @files.each { |file| yield(file) }
  end
  
  private
  
  def find_files
    @files = files_that_match_pattern 
    add_dirname_to_files
    remove_unfiles
  end
  
  def files_that_match_pattern
    Dir.entries(@directory).select { |file| file =! @pattern } 
  end
  
  def add_dirname_to_files
    @files.map! { |filename| File.join(@directory, filename) }
  end
  
  def remove_unfiles
    @files.delete_if { |file| !File.file?(file) }
  end
end