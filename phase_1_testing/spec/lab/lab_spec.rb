#!/bin/env ruby

$proj_dir = File.expand_path( "../../../", __FILE__ )   # phase_1_testing directory
require 'rspec'
require "#{$proj_dir}/lib/hl7_utils"
require "#{$proj_dir}/lib/extended_base_classes"
require "#{$proj_dir}/module/HL7.rb"
require 'set'

$in_file = "#{$proj_dir}/resources/manifest_lab_short_unix.txt"
PROV_SFX = /(STAR|MGH|MHM)PROV/

describe "Ohio Health HL7" do
  
  include HL7
  
  @mh = HL7::MessageHandler.new( $in_file )
  @msg_list = @mh.records

# == Loop through each message and test the data

  @msg_list.each do |message|
    
    @org = message[:MSH].sending_facility
    
# == General message tests

    it "has only one PID per message" do
      message[:PID].size.should == 1
    end

    it "has only one PV1 per message" do
      message[:PV1].size.should == 1
    end

    # == MSH tests
    context "MSH segment" do
      @msh = message[:MSH]

      it "is a results event" do
        @msh.event.should == "ORU^R01"
      end

      it "has the correct processing ID and version" do
        if @org == "MGH"
          @msh.processing_id.should be == "P"
          @msh.version.should == "2.3"
        else
          @msh.processing_id.should be == "T"
          @msh.version.should == "2.4"
        end
      end
      
    end #MSH context

    # == ORC tests
    context "ORC segment" do

      message[:ORC].each do |orc|
        
        it "has Control ID of two characters" do
          orc.order_control.should =~ /^\w{2}$/
        end
        
      end
      
    end #ORC context

    # == OBR tests   
    context "OBR segment" do
      
      message[:OBR].each do |obr|

        it "has a Control Code containing only letters, numbers, and spaces" do
          obr.control_code.should =~ /^[A-Za-z0-9 ]+$/
        end

        it "has a Procedure ID of only letters and numbers followed by an EAP signature" do
          obr1 = obr.procedure_id[0]
          obr4 = obr.procedure_id[3]

          obr1.should =~ /^[A-Za-z0-9]+$/
          obr4.should == ( @org == "MGH" ? "ECAREEAP" : "OHHOREAP" )
        end
      
        # Consider adding test for provider title e.g. MD, DO, etc...
        it "shows the Ordering Provider in the correct format" do
          prov = obr.ordering_provider
          
          HL7::is_a_name?( prov ).should be_true
          prov[6].should == "MD" || prov[6].should == "DO"
          prov[-1].should =~ PROV_SFX
        end

        # Make sure all possible status markers are in the regex
        it "has Result Status in the correct format" do
          HL7::RESULT_STATUS.include?( obr.result_status ).should be_true
        end

        it "has Date/Time values in the correct format" do
          HL7::is_a_datetime?( obr.observation_date_time ).should be_true
        end

        it "has Results Status Date that is the same as the Observation Date?" do
          obr.result_date_time.should == obr.observation_date_time
        end
   
      end
      
    end #OBR context

    # == OBX tests
    context "-- OBX child" do
      
      it "occurs directly after the OBR segment(s)" do
        message.segment_after( :OBR ).should be == :OBX
      end
      
      message[:OBX].each do |obx|

        # Consider checking elements 1 and 2 of this segment
        it "has the correct Component ID" do
          obx.component_id[-1].should == "LA01"
        end

        val_type = obx.value_type
        it "has an appropriate Observation Value for Value Type #{val_type}" do
          obval = obx.observation_value
          
          case
          when HL7::is_std_numeric?( obval )
            val_type.should == "SN"
          when HL7::is_numeric?( obval )
            val_type.should == "NM"
          when HL7::correct_timestamp_format?( obval )
            val_type.should == "TS"
          when !obval.empty?
            val_type.should == "TX"
          end   # empty values cannot really be tested
        end

        context "value has type of SN or NM" do
          if ( val_type == "SN" || val_type == "NM" )
            
            it "has valid Units" do
              UNITS.should include obx.units
            end

            it "has Reference Range in the correct format" do
              HL7::is_num_range?( obx.reference_range ).should be_true
            end

            it "has a valid Abnormal Flag" do
              ABNORMAL_FLAGS.should include obx.abnormal_flag
            end

          end
          
        end
        
      end
      
    end  # OBX context

    # == PID tests
    context "PID segment" do
      
      pid = message[:PID]

      it "has a valid patient ID" do
        pid.patient_id.first.should !~ /\D/      # should be entirely digits
        pid.patient_id.last.should =~ /\w+01/    # e.g. ST01
      end

      it "has a valid patient name" do
        name = pid[:patient_name]
        HL7::is_a_name?( name ).should be_true         # first/last name
        name[2].should !~ /[^A-Za-z]/                  # middle name - doesn't contain a non-letter
        HL7::is_extension?( name[3] ).should be_true   # extension, e.g. Jr. or III
      end

      it "has a valid date of birth" do
        HL7::is_a_datetime?( pid[:dob] )
      end

      it "has a valid sex" do
        SEXES.should include pid[:sex]
      end

      it "has a valid visit ID" do
        is_visit_id?( pid[:account_number] ).should be_true
      end
      
      it "shows the same visit ID in the patient information and the visit information"
        pid[:account_number].should == message[:PV1][:visit_number]
      end

      it "has a valid SSN" do
        pid.ssn.should =~ SSN
      end

    end #PID context

    # == PV1 tests
    context "PV1 segment" do
      pv1 = message[:PV1]

      it "has a valid visit ID" do
        is_visit_id?( pv1[:visit_number] ).should be_true
      end

      it "has a valid attending doctor" do
        HL7::is_a_name?( pv1.attending_doctor )
        pv1.attending_doctor.last.should =~ PROV_SFX
      end

      it "has the same Attending and Referring Doctor" do
        ref = pv1[:referring_doctor]
        ref.should == pv1[:attending_doctor] unless ref.empty?
      end

      it "does not have a single-digit Patient Class" do
        pv1.patient_class.should !~ /^\d{1}$/
      end

      it "has a valid Patient Type" do
        pv1.patient_type.should =~ /^\d{1,2}$/
      end

      it "no longer shows a VIP indicator" do
        pv1[16].should be_empty
      end

    end #PV1 context

    after(:each) do
      #puts "\nTest executed!"
      #puts "\nError found in:
            #{example.example_group.description} while testing it #{example.description}.
           # Message Tested:\n #{message.to_s}" unless example.exception.nil?
    end
    
  end # End of @msg_list.each
  
end

def is_visit_id?( val )
  val[0] =~ /^[A-Z]?\d+\^/ && val[-1] =~ /\^\w+ACC$/
end
