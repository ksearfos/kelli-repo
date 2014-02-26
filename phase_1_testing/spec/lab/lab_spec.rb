#!/bin/env ruby

require 'rspec'
require 'hl7_utils'

describe File do
  before(:all) do
    file = ""
    File.open( "../../lib/resources/manifest_lab_out" ) do |f|
        s = f.gets
        #blank lines cause HL7 Parse Error...
        #and ASCII line endings cause UTF-8 Error...
        file << s.force_encoding("binary").encode('utf-8', 
            :invalid => :replace, :undef => :replace).chomp
    end
    @msg = HL7::Message.new(file)
  end
  
  it 'has MSH segments with the correct Event format' do
    @msg.each do |s|
      s.e8.should match /ORU\^R01/ unless s.e0[/^\d+MSH$/].nil?
    end
  end
  
  it 'has PID segments with the correct Patient ID format' do
    @msg[:PID].each do |s|
      s.e3.should match /^\d*\^/
      s.e3.should match /\^\w+01$/
    end
  end

  it 'has ORC segments with Control ID of two characters' do
    @msg[:ORC].each do |s|
      s.e1.should match /^\w{2}$/
    end
  end
end
