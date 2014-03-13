# last run: 3/13/14 16:02
require 'spec_helper.rb'

describe "HL7" do
  
  describe "Lab Message" do
    
    before(:each) do
      @message = $lab_message
    end
    
    it "can be instantiated" do
      @message.should_not be_nil   
    end
    
    it "is of type :lab" do
      @message.type.should == :lab
    end
          
    it "allows access to the underlying text" do
      @message.original_text.should_not be_empty  
    end
    
    it "allows access to individual segments" do
      @message.segments.should_not be_empty  
    end
    
    it "can be output in a meaningful manner" do
      @message.to_s.should_not be_empty
    end
    
    it "can access a segment by name" do   
      @message[:PID].class.should eq $pid_cl
      @message[:PID].class.superclass.should eq HL7::Segment
    end
    
    context "iteration" do    
      it "can be forced to happen by segment" do
        count = 0
        @message.each_segment{ |f|
          count += 1 if f.is_a?( HL7::Segment )
        }

        count.should == @message.segments.size
      end
      
      it "will look through all segments and types by default" do
        count = 0
        @message.each{ |t,f|
          count += 1 if t.is_a?( Symbol ) && f.is_a?( HL7::Segment ) && f.type == t
        }
        count.should == @message.segments.size
      end
    end #context
            
    context "undefined method" do      
      it "will treat message as a String" do
        @message.gsub( '*', '|^\n' ).should == $lab_str.gsub( '*', '|^\n' ) 
      end
      
      it "will treat message as an Array" do
        expect {@message.shuffle}.not_to raise_error
      end
      
      it "will treat message as a Hash" do
        expect {@message.invert}.not_to raise_error   
      end
      
      it "alerts the user when an unknown method is called" do
        expect {@message.fakey_method}.to raise_error(NoMethodError) 
      end
      
      it "functions first as an Array" do
        @message.member?(:PID).should be_false  # :PID is member of @segments, but not of @segments.values
      end
    end # context
    
    it "allows quick access to the header" do
      @message.header.should == @message[:MSH]
    end
    
    it "allows quick viewing of segments" do
      put = capture_stdout{ @message.view_segments }
      put.should_not be_empty 
    end

    it "allows quick viewing of important information" do
      put = capture_stdout{ @message.view_details }
      put.should_not be_empty
    end
    
    it "allows quick access to all values in a specific field" do
      ff = @message.fetch_field("obr4")
      ff.should be_a Array
      ff.should == @message[:OBR].all_fields(4)
    end
    
    it "keeps track of segment order" do
      @message.segment_before(:PV1).should eq :PID
      @message.segment_after(:PID).should eq :PV1
    end
  end

end