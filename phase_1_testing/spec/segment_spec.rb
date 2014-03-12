# last run: 3/12/14 11:13 AM
# outcome: success

require 'spec_helper.rb'

describe "HL7" do
  
  describe "single-line Segment" do
    
    before(:each) do
      @segment = $segment
    end
    
    it "can be instantiated" do
      @segment.should_not be_nil   
    end
    
    it "is untyped by default" do
      cl = @segment.class
      cl.should eq HL7Test::Segment
      cl.is_eigenclass?.should be_false
    end
          
    it "allows access to the underlying text" do
      @segment.original_text.should_not be_empty  
    end
    
    it "allows access to individual fields" do
      @segment.fields.should_not be_empty  
    end
    
    it "can be output in a meaningful manner" do
      @segment.to_s.should_not be_empty
    end
    
    context "access to fields" do
      before(:each) do
        @i = 3
        @target = $seg_str.split('|')[@i-1]
      end
    
      it "can be done by index" do   
        @segment[@i].to_s.should eq @target
        @segment.field(@i).to_s.should eq @target
      end
    
      it "can be done by field name" do
        @segment[@i].to_s.should eq @target
        @segment.field(@i).to_s.should eq @target
      end
      
      it "can grab all relevant fields at once" do
        @segment.all_fields(@i).size.should == @segment.size
      end
    end #context
    
    context "iteration" do    
      it "can be forced to happen by field" do
        count = 0
        @segment.each_field{ |f|
          count += 1
        }

        count.should == @segment.fields.size
      end

      it "can be forced to happen by line" do
        count = 0
        @segment.each_line{ |l|
          count += 1
        }
        count.should == @segment.size
      end
      
      it "happens naturally by field" do
        count = 0
        @segment.each{ |f|
          count += 1
        }
        count.should == @segment.fields.size
      end
    end #context
            
    context "undefined method" do      
      it "will treat segment as a String" do
        @segment.gsub( '*', '|' ).should == $seg_str.gsub( '*', '|' ) 
      end
      
      it "will treat segment as an Array" do
        @segment.sort.should == $seg_str.split("|").sort
      end
      
      it "alerts the user when an unknown method is called" do
        expect {@segment.fakey_method}.to raise_error(NoMethodError) 
      end
      
      it "functions first as an Array" do
        @segment.index("19840402").should eql 6
        @segment.index("1").should be_nil
      end
    end # context
    
    it "allows quick viewing of fields" do
      put = capture_stdout{ @segment.view }
      put.should_not be_empty  
    end

  end

end