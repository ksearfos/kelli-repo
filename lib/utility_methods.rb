#!/bin/env ruby

# adds all directories in the project to $LOAD_PATH
def update_loadpath
  project_directory = File.expand_path( "../..", __FILE__ )   # filepath, minus filename and lib directory
  child_directories = find_all_directories( project_directory )
  $LOAD_PATH.unshift( child_diretories )
  $LOAD_PATH.unshift( project_directory )
  $LOAD_PATH.flatten!
end

def find_all_directories( parent_directory, recursive=true )
  directories = [ parent_directory ]
  subdirectories = []
  directories.each{ |directory|
    new_directories = Dir.glob( directory + "/*/" )  
    subdirectories += new_directories
    directories += new_directories if recursive   # additions will then get iterated through with the each
  }
  
  subdirectories
end
