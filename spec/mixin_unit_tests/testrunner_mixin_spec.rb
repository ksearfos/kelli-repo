$LOAD_PATH.unshift File.expand_path("../../..", __FILE__)   # project directory
$LOAD_PATH.unshift File.dirname(__FILE__)
require 'spec_helper'

describe "TestRunnerMixin" do
  
  before(:all) do
  	@test_runner_object = SpecHelperClass.new
  end
  
  it "adds a suite of instance variables to an including class",
  :detail => "once set_common_instance_variables() is called" do
  	@test_runner_object.instance_variables.should_not be_empty  # SpecHelperClass does call the method in initialize
  end
  
  it "adds methods to an including class" do
    @test_runner_object.methods.should_not be_empty
  end	
  
   describe "#set_common_instance_variables" do
    it "sets the values of instance variables" do
      @test_runner_object.instance_variable_get(:@message_type).should eq :enc
      @test_runner_object.instance_variable_get(:@debugging).should eq true
    end
  end 
  
  describe "#log_file_name" do
  	it "returns a String named after the including class", :detail => "lowercased and with '_' between words" do
  	  @test_runner_object.log_file_name.should include "spec_helper_class"
      @test_runner_object.log_file_name.should_not include "any_other_class"
  	end
  end
  
end
