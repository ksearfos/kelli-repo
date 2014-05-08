require 'working_folder/subset_finder'

def run(type, input_directory)
  finder = SubsetFinder.new(type, input_directory)
  finder.run
  finder.result
end