shared_examples TestRunner do
  it "can be instantiated" do
    expect(runner).not_to be_nil
  end

  it "is associated with a specific record type" do
    expect(runner.record_type).to eq(record_type)
  end
  
  it "logs activity" do
    expect(runner.logger).not_to be_nil
  end
  
  describe "#get_files" do
    it "retrieves the files to interact with" do
      FileIO.stub(:get_files) { %w(file1.txt file2.txt file3.txt) }   
      expect(runner.get_files("file pattern").size).to eq(3)
    end 
  end
  
  describe "#shutdown" do
    it "closes the logger" do
      runner.logger.should_receive(:close)
      runner.shutdown
    end
  end
end