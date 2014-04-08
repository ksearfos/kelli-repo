require 'classes/AutomatedTestsRunner'
require 'classes/RecordComparerRunner'
require 'classes/TestRunner'
require 'rspec'
require 'rspec/expectations'

RSpec.configure do |c|
  c.fail_fast = true
end

class TestRecordComparerRunner < RecordComparerRunner
  attr_reader :input_directory, :logger, :results_file
  
  def initialize
    @debugging = true
    @message_type = :lab  
    @minimum_size = 5
    @input_directory = "#{File.dirname(__FILE__)}/test_data"
    @logger = CustomizedLogger.new("#{@input_directory}/logs", self.class.log_file_name)   
    @input_file_pattern = /#{@message_type}_pre_\d/
    @results_file = "#{@logger.directory}/#{RESULTS_FILENAME}"
    @temp_file = "#{@logger.directory}/#{TEMP_FILENAME}"
    @csv_file = ""
    @comparer = nil
  end
  
  # wrapper to call private methods
  def call_private(method, *args)
    send(method, *args)
  end
end