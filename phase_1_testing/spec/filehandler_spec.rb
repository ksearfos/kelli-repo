# last run: 3/13/14 16:01

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
      @hdler.messages.should_not be_empty  
    end
    
    it "allows access to the list of separators" do
      @hdler.separators.sort.should == HL7.separators.values.sort 
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
        count.should == @hdler.messages.size
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
    
    describe "view_separators" do
      it "writes a list of separators to stdout" do
        put = capture_stdout{ @hdler.view_separators }
        put.should_not be_empty  
      end
    end  
    
  end
end