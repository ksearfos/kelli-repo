# last run: 3/25/14 at 13:44

require 'spec_helper.rb'

describe "HL7" do
  describe "FileHandler" do
    
    before(:each) do
      @hdler = $file_handler
    end
    
    it "requires a valid filename" do
      expect {HL7::FileHandler.new("c:/fakey_file.txt")}.to raise_error(HL7::FileError)
    end
    
    it "can be instantiated" do
      @hdler.should_not be_nil   
    end
    
    it "allows access to the underlying text" do
      @hdler.file_text.should_not be_empty  
    end
    
    it "allows access to individual records" do
      @hdler.records.should_not be_empty  
    end
    
    describe "to_s" do
      it "conerts a FileHandler to a String object" do
        @hdler.to_s.should be_a String
      end
    end
    
    describe "square-brackets []" do
      it "allow access to records by index" do
        @hdler[0].should be_a( HL7::Message )
      end
    end
  
    describe "each" do
      it "iterates through the messages" do
        count = 0
        @hdler.each{ |rec|
          count += 1
          rec.should be_a HL7::Message
        }
        count.should == @hdler.records.size
      end
    end
    
    describe "method_missing" do
      it "will treat FileHandler as a String" do
        expect {@hdler.gsub( '*', '^|' )}.not_to raise_error
      end
      
      it "will treat FileHandler as an Array" do
        expect {@hdler.shuffle}.not_to raise_error
      end
      
      it "alerts the user when an unknown method is called" do
        expect {@hdler.fakey_method}.to raise_error(NoMethodError) 
      end
      
      it "looks for a match in the Array class first" do
        @hdler.reverse.should be_a Array
      end
    end 

    describe "next" do
      it "changes the value of @records" do
        old = @hdler.records
        @hdler.next
        old.should_not == @hdler.records
      end
      
      it "iterates through a large number of records" do
        file = "C:/Users/Owner/Documents/script_input/rad_post.txt"
        hdlr = HL7::FileHandler.new( file, 10 )
        hdlr.records.size.should eq 10
        hdlr.next
        hdlr.records.should_not be_empty
        
        @hdler.next
        @hdler.records.should be_empty
      end   
    end    
  end
end