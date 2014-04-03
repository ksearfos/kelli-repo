$LOAD_PATH.unshift File.expand_path("../../..", __FILE__)   # project directory
require 'spec/test_runner_mixin/spec_helper'

describe "ComparerMixin" do
  
  before(:all) do
  	@test_runner_object = SpecHelperComparerClass.new
  	@messages = HL7::FileHandler.new("#{File.dirname(__FILE__)}/test_data.txt").records
  end
  
  describe "#set_up_comparer" do
    it "creates and sets the instance variable @comparer" do
      @test_runner_object.set_up_comparer(@messages, false)
      @test_runner_object.instance_variable_defined?(:@comparer).should be_true
    end
    
    it "creates a new RecordComparer object", :detail => "this includes OrgSensitiveRecordComparer, a child class" do
      @test_runner_object.set_up_comparer(@messages, true)
      @test_runner_object.comparer.should be_a RecordComparer
      @test_runner_object.comparer.should be_a OrgSensitiveRecordComparer
    end
  end
  
end
