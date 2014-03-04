#!/bin/env ruby
$proj_dir = File.expand_path( "../../../", __FILE__ )   # phase_1_testing directory
require 'rspec'
require 'rspec/expectations'
require "#{$proj_dir}/lib/hl7_utils"
require "#{$proj_dir}/lib/extended_base_classes"
require 'set'
require 'logger'


# == Methods and Objects we will use

known_units = ["","%","/hpf","/lpf","/mcL","IU/mL","K/mcL","M/mcL","PG",
               "U","U/L","U/mL","fL","g/dL","h","lbs","log IU/mL",
               "mIU/mL","mL","mL/min/1.73 m2","mcIU/mL","mcg/dL",
               "mcg/mL FEU","mg/24 h","mg/L","mg/dL","mg/g crea",
               "mlU/mL","mm Hg","mm/hr","mmol/L","ng/dL","ng/mL",
               "nmol/L","pH units","pg/mL","seconds","titer",
               "weeks","years"]

abnormal_flags = ["","I","CH","CL","H","L","A","U","N","C"]

def get_obx_of_obr( obr )
  obr.children.select { |s|
          s.is_a? HL7::Message::Segment::OBX }
end

def full_description( example )
  example.metadata[:full_description]
end

def log_example_exception( example, message )
  exception_message = example.exception.to_s.split("Diff:")[0]

  $logger.error "#{'*'*80}\n    Error found in:
#{example.metadata[:full_description]}\n
    Example Exception:\n#{cap_first( exception_message )}
    Pattern translation:\n#{cap_first( example.metadata[:pattern] )}\n
    Message Tested:\n#{message.to_s}\n#{'*'*80}\n"
end

def cap_first( string )
  string.slice(0,1).capitalize + string.slice(1..-1)
end

# == Get data to test

raw_hl7 = ""
# try to get the file passed to the run script
if ENV["FILE"].nil?
  @file_to_open = File.join( "#{$proj_dir}","resources","lab_hl7","manifest_lab_out_short" )
else
  @file_to_open = ENV["FILE"]
end
#blank lines cause HL7 Parse Error...
File.open( @file_to_open, "rb" ) do |f|
  #blank lines cause HL7 Parse Error...
  #and ASCII line endings cause UTF-8 Error..
  while s = f.gets do
    t = s.force_encoding("binary").encode("utf-8", 
        :invalid => :replace, :undef => :replace)
    raw_hl7 << t.chomp + "\n"
  end
end

msg_list = orig_hl7_by_record raw_hl7

# == Set up the logger
@time = DateTime.now.strftime("%F at %T")
@logfilename = ( File.basename(@file_to_open) + '_' + @time.gsub('at', '-') ).gsub(' ', '').gsub(':', '-')
$logger = Logger.new("#{File.join($proj_dir, "log", "lab", @logfilename)}.log")

$logger.formatter = proc do |severity, datetime, progname, msg|
  "#{severity}: #{msg}\n"
end
  
$logger.info "Automated Testing Log for #{File.basename(@file_to_open)}\n"

$logger.info "Number of records tested: #{msg_list.size}\n"

$test_descriptions = Set.new

# == Configure RSpec

RSpec.configure do |config|
  config.after(:suite) do
    $logger.info "#{'*'*80}\nElements Tested For:\n"
    $test_descriptions.each do |desc|
      $logger.info desc
    end
  end
end

# == Loop through each message and test the data

msg_list.each do |message|

# == Describe the tests

  describe "Ohio Health HL7" do

# == General message tests

    it "has only one PID per message", :pattern => '' do
      message.children[:PID].size.should == 1
    end

    it "has only one PV1 per message", :pattern => '' do
      message.children[:PV1].size.should == 1
    end

# == MSH tests
    # Field names do not work unless converted to HL7::Segment::MSH
    context "MSH segment" do
      msh = message[0]

      it "has MSH segments with the correct Event format", :pattern => 'ORU^R01' do
        msh.e8.should match /^ORU\^R01$/
      end

      it "has a valid Message Control ID", :pattern => 'P or T' do
        if msh.e3 =~ /MGH/
          msh.e10.should match /^P$/
        else
          msh.e10.should match /^T$/
        end
      end

      it "has the correct Processing ID", :pattern => '2.3 or 2.4' do
        if msh.e3 =~ /MGH/
          msh.e11.should match /^2.3$/
        else
          msh.e11.should match /^2.4$/
        end
      end

    end

# == ORC tests

    context "ORC segment", :pattern => 'any two characters' do
      message[:ORC].each do |orc|

        it "has Control ID of two characters" do
          orc.order_control.should match /^\w{2}$/
        end

      end
    end

# == OBR tests
    
    context "OBR segment" do
      message[:OBR].each do |obr|

        it "has Control Code containing only letters, numbers, and spaces", 
              :pattern => 'one or more characters and/or numbers with spaces allowed' do
          obr.filler_order_number.should match /^[A-Za-z0-9][A-Za-z0-9 ]*/
        end

        it "has Procedure ID in the correct format", 
            :pattern => 'begins with capital letters and numbers and ends with ECAREEAP or OHHOREAP' do
          obr.universal_service_id.should match /^[A-Z0-9]+\^/
          if message[0].e3 =~ /MGH/
            obr.universal_service_id.should match /\^ECAREEAP$/
          else
            obr.universal_service_id.should match /\^OHHOREAP$/
          end
        end
      
        # Consider adding test for provider title e.g. MD, DO, etc...
        it "has Ordering Provider in the correct format", 
            :pattern => 'an optional capital letter followed by numbers, lastname, firstname, optional middle initial, final field ends with PROV' do
          obr.ordering_provider.should match /^[A-Z]?[0-9]+\^[A-Z a-z\-]+\^[A-Z a-z]+\^[A-Z]?\^/
          obr.ordering_provider.should match /\^\w+PROV$/
        end

        # Make sure all possible status markers are in regex
        it "has Result Status in the correct format", :pattern => 'any single letter in [DFNOSWPXCRUI]' do
          obr.result_status.should match /^[DFNOSWPCXRUI]$/
        end

        it "has Date/Time values in the correct format", 
            :pattern => 'a timestamp in yyyyMMddHHmm format' do
          # yyyyMMddHHmm
          obr.observation_date.should match /^(19|20)\d\d(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])((0|1)[0-9]|2[0-3])(0[0-9]|[1-5][0-9])$/
        end

        it "has Results Status Date that is the same as the Observation Date", 
            :pattern => 'matching dates' do
          obr.results_status_change_date.should eq obr.observation_date
        end
   
# == OBX tests

        context "-- OBX child" do
          obx_children = get_obx_of_obr( obr )
          obx_children.each do |obx|

            # Consider checking elements 1 and 2 of this segment
            it "has Component Id in the correct format", :pattern => 'LA01' do
              obx.observation_id.should match /\^LA01$/
            end

            value_type = obx.value_type
            it "has an appropriate Observation Value for Value Type #{value_type}",
                :pattern => 'depends on the value type...
If SN: an optional < or > or <= or >= or =, an optional + or -, number(s), an optional separator (., +, /, :, -), and number(s) following the separator
If NM: an optional + or -, number(s), an optional decimal point, and numbers following the decimal
If TX: a string of text that is not obviously an SN or NM
If TX: a timestamp in MM-dd-yyyy hh:mm format' do
              if value_type =~ /^SN$/
                obx.observation_value.should match /^[<>]?[=]? ?[\+-]? ?\d+[\.\+\/:-]?\d* ?$/
              elsif value_type =~ /^NM$/
                obx.observation_value.should match /^ ?[\+-]? ?\d+\.?\d* ?$/
              elsif value_type =~ /^TX$/
                obx.observation_value.should_not match /^[<>]?[=]? ?[\+-]? ?\d+[\.\+\/:-]?\d* ?$/
              elsif value_type =~ /^TS$/
                # MM-dd-yyyy hh:mm
                obx.observation_value.should match /^(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])-(19|20)\d\d ((0|1)[0-9]|2[0-3]):(0[0-9]|[1-5][0-9]) $/
              else
                fail
              end
            end

            context "with value type of SN or NM" do
              if obx.value_type =~ /^(SN|NM)$/

                it "has valid Units", :pattern => 'units in #{known_units.to_s}' do
                  known_units.should include obx.units
                end

                it "has Reference Range in the correct format", 
                  :pattern => 'a positive or negative number - another number' do
                  obx.references_range.should match /^(-?\d+\.?\d*-\d+\.?\d*)?$/
                end

                it "has a valid Abnormal Flag", :pattern => 'a flag in #{abnormal_flags.to_s}' do
                  abnormal_flags.should include obx.abnormal_flags
                end

              end # End obx.value_type if
            end # End Values of Type SN or NM Context
          
          end # End of obx_children.each
        end  # End of OBX context

      end # End of message[:OBR].each
    end # End of OBR context

# == PID tests

    context "PID segment" do
        
      pid = message.children[:PID][0]

      it "has PID segments with the correct Patient ID format", :pattern => 'begins with digits and ends with characters followed by "01"' do
        pid.patient_id_list.should match /^\d*\^/
        pid.patient_id_list.should match /\^\w+01$/
      end

      it "has Patient Name in the correct format", 
          :pattern => 'lastname, firstname, optional initial, JR. or SR. or Roman Numeral' do
        # Lastname^Firstname^I^JR.|SR.|RomanNumeral
        pid.patient_name.should match /^\w+([- ]{1}\w+)*\^\w+(\^|\^[A-Z])?(\^((JR|SR)\.|((II|III|IV|V))))?$/
      end

      it "has Date of Birth in the correct format", :pattern => 'year month day (yyyyMMdd)' do
        # yyyyMMdd
        pid.patient_dob.should match /^(19|20)\d\d(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])$/
      end

      it "has Sex in the correct format", :pattern => 'one of [FMOUANC]' do
        # F|M|O|U|A|N|C
        pid.admin_sex.should match /^[FMOUANC]$/
      end

      it "has Visit ID in the correct format", 
          :pattern => 'begins with an optional capital letter followed by numbers and ends with characters followed by "ACC"' do
        pid.account_number.should match /^[A-Z]?\d+\^/
        pid.account_number.should match /\^\w+ACC$/
      end

      it "has SSN in the correct format", :pattern => 'a social security number without dashes' do
        pid.social_security_num.should match /^\d{9}$/
      end

    end # End of PID Context

# == PV1 tests

    context "PV1 segment" do
       pv1 = message.children[:PV1][0]

      it "has Visit ID in the correct format", 
          :pattern => 'an optional capital letter followed by digits, ending with characters followed by "ACC"' do
        pv1.visit_number.should match /^[A-Z]?\d+\^/
        pv1.visit_number.should match /\^\w+ACC$/
      end

      it "has Visit ID that matches PID Visit ID", 
          :pattern => 'Visit ID and PID Visit ID fields should match' do
        pid = message.children[:PID][0]
        pv1.visit_number.should eq pid.account_number 
      end

      it "has an Attending Doctor in the correct format", 
          :pattern => 'begins with an optional P followed by digits (or 000000 if there is no doctor assigned), ends with STARPROV or MGHPROV or MHMPROV' do
        pv1.attending_doctor.should match /^(P?[1-9]\d+|000000)\^/
        pv1.attending_doctor.should match /\^(STAR|MGH|MHM)PROV$/
      end

      it "has the same Attending and Referring Doctor", :pattern => 'fields should match unless Referring Doctor field is empty' do
        pv1.referring_doctor.should eq pv1.attending_doctor unless pv1.referring_doctor.empty?
      end

      it "does not have a single digit Patient Class", :pattern => 'a single digit' do
        pv1.patient_class.should_not match /^\d{1}$/
      end

      it "has a one or two digit Patient Type", :pattern => 'one or two digits' do
        pv1.patient_type.should match /^\d{1,2}$/
      end

      it "does not have a VIP Indicator", :pattern => 'this field should be empty' do
        pv1.vip_indicator.should be_empty
      end

    end # End of PV1 Context

    after(:each) do
      $test_descriptions.add( full_description( example ) )
      log_example_exception( example, message ) unless example.exception.nil?
    end
      
  end # End of Describe Ohio Health HL7 Message
end # End of msg_list.each


# == Helper methods 

def get_units( obx_list )
  unit_set = Set.new
  obx_list.each do |obx|
    if obx.value_type =~ /^(SN|NM)$/
      unit_set.add obx.units.to_s
    end
  end
  unit_set.each do |unit|
    puts unit.to_s
  end
  unit_set
end
