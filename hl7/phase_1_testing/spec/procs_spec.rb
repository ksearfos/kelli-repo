require 'rspec'

proj_dir = File.expand_path( "../..", __FILE__ )
require "#{proj_dir}/Record_Comparer/OHProcs.rb"
require "#{proj_dir}/spec/spec_helper.rb"

include OHProcs

# $rad_message[:OBR].view

# RESULT_STATUS = %w[ D F N O S W P C X R U I ]
# SEXES = %w[ F M O U A N C ]
# ABNORMAL_FLAGS = %w[ I CH CL H L A U N C ]

# order, then rad,
$procs = PID8_VALS

describe "OhioHealth Procs module" do
  describe "proc" do
 
    $procs.each{ |name,proc|
      it "#{name} works" do
        proc.call($rad_message).should be_true
      end
      
    }
  end
end
