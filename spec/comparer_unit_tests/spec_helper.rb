$LOAD_PATH.unshift File.expand_path("../../../", __FILE__)
require 'classes/RecordComparer'
require 'classes/SizedRecordComparer'
require 'rspec'
require 'rspec/expectations'
require 'rspec/mocks'

RSpec.configure do |c|
  c.fail_fast = true
  c.formatter = :documentation
end

class TestRecord
  def initialize
    @chosen = false
  end
  
  def choose
    @chosen = true
  end
  
  def unchoose
    @chosen = false
  end
  
  def chosen?
    @chosen
  end
end

$redundant_record = TestRecord.new
$duplicate_record = TestRecord.new
$needed_record = TestRecord.new
$extra_record = TestRecord.new
$all_records = [$needed_record, $redundant_record, $duplicate_record, $extra_record]
$criteria = [:criterion1, :criterion2]
