# passed testing 4/7
$LOAD_PATH.unshift File.expand_path("../../..", __FILE__)   # project directory
$LOAD_PATH.unshift File.dirname(__FILE__)
require 'spec_helper'

describe "ComparerMixin" do
  
  before(:all) do
  	@test_runner = SpecHelperComparerClass.new
  	@messages = HL7::FileHandler.new("#{File.dirname(__FILE__)}/test_data.txt").records
  end
  
  describe "#set_up_comparer" do
    before(:all) do
      @test_runner.set_up_comparer(@messages)
    end
    
    it "creates and sets the instance variable @comparer" do
      @test_runner.instance_variable_defined?(:@comparer).should be_true
    end
    
    it "creates a new RecordComparer object" do
      @test_runner.comparer.should be_a RecordComparer
    end
  end
  
  describe "#set_up_org_sensitive_comparer" do
    before(:all) do
      @test_runner.set_up_org_sensitive_comparer(@messages)
    end
    
    it "creates and sets the instance variable @comparer" do
      @test_runner.instance_variable_defined?(:@comparer).should be_true
    end
    
    it "creates a new OrgSensitiveRecordComparer object" do
      @test_runner.comparer.should be_a OrgSensitiveRecordComparer
    end
  end
  
end
