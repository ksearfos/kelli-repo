# passed as of 4/7/14
$LOAD_PATH.unshift File.expand_path("../../..", __FILE__)   # project directory
$LOAD_PATH.unshift File.dirname(__FILE__)
require 'spec_helper'

describe "TestRunnerFileHandling" do
  
  before(:all) do
  	@test_runner = SpecHelperClass.new
  end
    
  describe "#get_files" do
    before(:each) do
      @directory = File.dirname(__FILE__)
    end        
      
    it "returns an Array of files in #{@directory}" do
      files = @test_runner.get_files(@directory)
      files.should_not be_empty
      files.first.should =~ /\w+\.\w+/    # text/text.ext
    end
      
    pattern = /_spec\.rb\z/
    it "only returns files matching the pattern #{pattern}" do
      files = @test_runner.get_files(@directory, pattern)
      files.each { |file| file.should =~ pattern } 
    end
  end
    
  describe "#get_hl7_files" do
    it "returns an Array of hl7_files in default directory" do
      files = @test_runner.get_hl7_files
      files.should_not be_empty
      files.each { |file| file.should =~ @test_runner.input_file_pattern } 
    end
  end
    
  describe "#create_file_handler" do
    before(:each) do
      @directory = "#{File.dirname(__FILE__)}/directory_with_2_files"
    end
  
    it "creates a FileHandler object from a non-empty file" do
      file_handler = @test_runner.create_file_handler("#{@directory}/nonempty_file")
      file_handler.should_not be_nil
      file_handler.should be_a HL7::FileHandler
    end
      
    it "returns nil and removes the file if the file is empty" do
      file = "#{@directory}/empty_file"
      file_handler = @test_runner.create_file_handler(file)
      file_handler.should be_nil
      File.exists?(file).should_not be_true
    end
      
    after(:all) do
      # file got removed; put it back!
      File.open("#{File.dirname(__FILE__)}/directory_with_2_files/empty_file", "w") { |file| print "" } 
    end
  end
  
  describe "#file_date_string" do
    it "returns date found in filename" do
      @test_runner.file_date_string("abc_123456.ext").should == "123456"
    end
    
    it "uses @timestamp if no date in file" do
      @test_runner.file_date_string("abc_onetwothree.ext").should == @test_runner.timestamp
    end
  end
end
