# last run: 3/12/14 14:09
# outcome: success

require 'spec_helper.rb'

describe "HL7" do
  describe "MessageHandler" do
    
    before(:each) do
      @mh = $message_handler
    end
    
    it "can be instantiated" do
      @mh.should_not be_nil   
    end
    
    it "allows access to the underlying text" do
      @mh.message.should_not be_empty  
    end
    
    it "allows access to individual records" do
      @mh.records.should_not be_empty  
    end
    
    it "can be output in a meaningful manner" do
      @mh.to_s.should_not be_empty
    end
    
    it "allows access to records by index" do
      @mh[0].should be_a( HL7Test::Message )
    end
    
    it "can be iterated through" do
      count = 0
      @mh.each{ |rec|
        count += 1
        rec.should_not be_nil
      }
      count.should == @mh.records.size
    end
    
    context "undefined method" do
      it "will treat MessageHandler as a String" do
        expect {@mh.gsub( '*', '^|' )}.not_to raise_error
      end
      
      it "will treat MessageHandler as an Array" do
        expect {@mh.shuffle}.not_to raise_error
      end
      
      it "alerts the user when an unknown method is called" do
        expect {@mh.fakey_method}.to raise_error(NoMethodError) 
      end
      
      it "functions first as an Array" do
        @mh.reverse.should be_a Array
      end
    end # context
    
    it "allows access to the separators used in the messages" do
      put = capture_stdout{ @mh.view_separators }
      put.should_not be_empty  
      
      @mh.separators.sort.should == [ '|', '^', '~', '\\', '&' ].sort 
    end
  
  end
end