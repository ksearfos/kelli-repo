# passed testing 4/7
$LOAD_PATH.unshift File.expand_path("../../..", __FILE__)   # project directory
$LOAD_PATH.unshift File.dirname(__FILE__)
require 'spec_helper'

describe "TestRunner class" do
  
  describe "#log_file_name" do
    it "returns a file name based on the class name" do
      TestRunner.log_file_name.should include "test_runner"
      SpecHelperClass.log_file_name.should include "spec_helper_class"
    end
    
    it "includes a unique timestamp" do
      TestRunner.log_file_name.should include TestRunner.timestamp
    end
  end

end
