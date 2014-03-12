# last run: 3/12/14 13:07
# outcome: success

require 'spec_helper.rb'

describe "HL7" do
  describe "Field" do
    
    before(:each) do
      @field = $field
    end
    
    it "can be instantiated" do
      @field.should_not be_nil   
    end
    
    it "allows access to the underlying text" do
      @field.original_text.should_not be_empty  
    end
    
    it "allows access to individual components" do
      @field.components.should_not be_empty  
    end
    
    it "can be output in a meaningful manner" do
      @field.to_s.should_not be_empty
    end
    
    it "allows access to components by index" do
      @field[3].should == $str.split('^')[3]
    end
    
    it "can be iterated through" do
      count = 0
      @field.each{ |f|
        count += 1
        f.should_not be_nil
      }
      count.should == @field.components.size
    end
    
    context "undefined method" do
      it "will treat field as a String" do
        @field.gsub( '*', '^' ).should == $str.gsub( '*', '^' )  
      end
      
      it "will treat field as an Array" do
        @field.sort.should_not be_nil
      end
      
      it "alerts the user when an unknown method is called" do
        expect {@field.fakey_method}.to raise_error(NoMethodError) 
      end
      
      it "functions first as an Array" do
        @field.index("20535").should eql 0
        @field.index("2").should be_nil
      end
    end # context
    
    it "allows quick viewing of components" do
      put = capture_stdout{ @field.view }
      put.should_not be_empty  
    end
    
    context "format" do
      context "date" do
        before(:each) do
          @field = $date_field
        end
      
        it "can be a date separated with slashes" do
          @field.as_date.should include "/"
        end
        
        it "can be a date separated however the user wishes" do
          @field.as_date("**").should include "**"
        end        
      end #date context
        
      context "time" do
        before(:each) do
          @field = $time_field
        end
        
        it "can be a time on the 12-hour clock" do
          @field.as_time[0...2].to_i.should == 2
        end
      
        it "can be a time on the 24-hour clock" do
          @field.as_time(true)[0...2].to_i.should == 14
        end
      end #time context
      
      context "date-time" do
        before(:each) do
          @field = $dt_field
        end
        
        it "can be a date and time together" do
          dt = @field.as_datetime
          dt_ary = dt.split(" ")
          dt_ary.first.should eq $date_field.as_date          
          dt_ary[1..-1].join(" ").should == $time_field.as_time
        end    
      end #datetime context
      
      context "name" do       
        context "has lots of components" do
          before(:each) do
            @field = $name_field
          end
          
          it "shows full name, prefix, suffix, and degree" do
            @field.as_name.should == $name_str_as_name
          end
        end  
        
        context "has only a few components" do
          before(:each) do
            @field = $sm_name_field
          end
          
          it "shows first, last, and suffix" do
            @field.as_name.should == $sm_name_str_as_name
          end
        end         

      end #name context
    end #context
  
  end
end