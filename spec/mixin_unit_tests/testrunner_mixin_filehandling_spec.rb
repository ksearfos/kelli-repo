$LOAD_PATH.unshift File.expand_path("../../..", __FILE__)   # project directory
$LOAD_PATH.unshift File.dirname(__FILE__)
require 'spec_helper'

describe "TestRunnerMixin" do
  
  before(:all) do
  	@test_runner_object = SpecHelperClass.new
  end
  
  describe "::FileHandling" do
    
    describe "#get_files" do
      before(:each) do
        @directory = File.dirname(__FILE__)
      end        
      
      it "returns an Array of files in #{@directory}" do
        files = @test_runner_object.get_files(@directory)
        files.should_not be_empty
        files.first.should =~ /\w+\.\w+/    # text/text.ext
      end
      
      pattern = /_spec\.rb\z/
      it "only returns files matching the pattern #{pattern}" do
        files = @test_runner_object.get_files(@directory, pattern)
        files.each { |file| file.should =~ pattern } 
      end
      
      it "updates the logger" do
        do_and_verify_logger_updated(@test_runner_object.logger.file) do
          @test_runner_object.get_files(@directory)
        end.should be_true
      end
    end
    
    describe "#create_file_handler" do
      before(:each) do
        @directory = "#{File.dirname(__FILE__)}/directory_with_2_files"
      end
  
      it "creates a FileHandler object from a non-empty file" do
        file_handler = @test_runner_object.create_file_handler("#{@directory}/nonempty_file")
        file_handler.should_not be_nil
        file_handler.should be_a HL7::FileHandler
      end
      
      it "returns nil and removes the file if the file is empty" do
        file = "#{@directory}/empty_file"
        file_handler = @test_runner_object.create_file_handler(file)
        file_handler.should be_nil
        File.exists?(file).should_not be_true
      end
      
      after(:all) do
        # file got removed; put it back!
        File.open("#{File.dirname(__FILE__)}/directory_with_2_files/empty_file", "w") { |file| print "" } 
      end
    end
  end
  
end
