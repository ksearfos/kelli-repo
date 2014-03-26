# last run: 3/13/14 16:33

require 'spec_helper.rb'

describe "HL7" do  
  describe "Message" do
    
    before(:each) do
      @message = $lab_message
    end
    
    it "can be instantiated" do
      @message.should_not be_nil   
    end
          
    it "allows access to the underlying text" do
      @message.original_text.should_not be_empty  
    end
    
    it "allows access to individual segments" do
      @message.segments.should_not be_empty  
    end
    
    describe "to_s" do
      it "converts a Message to a String object" do
        @message.to_s.should be_a String
      end
    end
    
    describe "square-brackets []" do
      it "allow access to a segment by segment type" do   
        @message[:PID].class.should eq $pid_cl
        @message[:PID].should be_a HL7::Segment
      end
    end
    
    describe "each_segment" do    
      it "iterates through each segment" do
        count = 0
        @message.each_segment{ |f|
          count += 1
          f.should be_a HL7::Segment
        }

        count.should == @message.segments.size
      end
    end
    
    describe "each" do
      it "will iterate through both segments and their types" do
        count = 0
        @message.each{ |t,f|
          count += 1
          t.should be_a Symbol 
          f.should be_a HL7::Segment
          f.type.should == t
        }
        
        count.should == @message.segments.size
      end
    end
            
    describe "method_missing" do      
      it "will treat the Message as a String" do
        @message.gsub( '*', '|^\n' ).should == $lab_str.gsub( '*', '|^\n' ) 
      end
      
      it "will treat the Message as an Array" do
        expect {@message.shuffle}.not_to raise_error
      end
      
      it "will treat the Message as a Hash" do
        expect {@message.invert}.not_to raise_error   
      end
      
      it "alerts the user when an unknown method is called" do
        expect {@message.fakey_method}.to raise_error(NoMethodError) 
      end
      
      it "looks for a match in the Array class first" do
        @message.member?(:PID).should be_false  # :PID is member of @segments (Hash), but not of @segments.values (Array)
      end
    end
    
    describe "header" do
      it "allows quick access to the header" do
        @message.header.should == @message[:MSH]
      end
    end
    
    describe "view_segments" do
      it "prints the message's segments to stdout" do
        put = capture_stdout{ @message.view_segments }
        put.should_not be_empty 
      end
    end
    
    describe "view_details" do
      it "prints details about the message to stdout" do
        put = capture_stdout{ @message.view_details }
        put.should_not be_empty
      end
    end
    
    describe "details" do
      it "allows quick access to the details of the message" do
        @message.details.should_not be_empty
        @message.details(:id,:pt_name).keys.should == [:ID,:PT_NAME]
      end
    end
    
    describe "fetch_field" do
      it "allows quick access to all values in a specific field" do
        ff = @message.fetch_field("obr4")
        ff.should be_a Array
        ff.size.should == @message[:OBR].size
      end
    end
    
    describe "segment_before" do
      it "identifies the preceeding segment" do
        @message.segment_before(:PV1).should == :PID
      end
    end  
    
    describe "segment_after" do
      it "identifies the succeeding segment" do
        @message.segment_after(:PID).should == :PV1
      end
    end
    
  end
end