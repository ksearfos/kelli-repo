#!/bin/env ruby

proj_dir = File.expand_path( "../../..", __FILE__ )
# FILE = "#{proj_dir}/resources/manifest_lab_out_short"
FILE = "C:/Users/Owner/Documents/manifest_rad_out_shortened.txt"
$seg = "PID|||00487630^^^ST01||Thompson^Richard^L||19641230|M|||^^^^^^^|||||||A2057219^^^^STARACC|291668118"
$field = "Thompson^Richard^L^III"

require 'rspec'
require "#{proj_dir}/module/HL7"

describe "HL7::Field" do

  it "correctly formats strings" do
    @field = HL7::Field.new( "Thompson^Richard^L^III" )
    @field.as_name.should == "Richard L Thompson III"
  end
  
  it "correctly formats dates and times" do
    @field = HL7::Field.new( "19641230" )
    @field.as_date.should == "12/30/1964"
  end
  
  it "corretly formats dates with changeable delimiter" do
    @field = HL7::Field.new( "19641230" )
    @field.as_date('-').should == "12-30-1964"    
  end
end

=begin
describe "HL7::MessageHandler" do
  before(:each) do
    @mh = HL7::MessageHandler.new( FILE )
  end
  
  it "parses correctly" do
    @mh.should_not be_nil
  end
  
  it "removes carriage returns" do
    @mh.message.should_not include?( "\r" )
  end
  
  it "contains 5 records" do
    @mh.records.size.should == 5
  end
end
=end