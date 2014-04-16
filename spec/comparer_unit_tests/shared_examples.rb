shared_examples RecordComparer do    
  it "has a list of record-criteria maps" do
    expect(comparer).to respond_to :list_of_maps
  end
  
  describe "#reset" do
    it "chooses all records" do   
      comparer.reset
      expect(comparer.chosen.size).to eq(comparer.list_of_maps.maps.size)
    end
  end 
  
  describe "#chosen" do    
    it "returns a list of the records chosen" do
      expect(comparer.chosen).to be_a Array
    end
  end

  describe "#unchosen" do    
    it "returns a list of the records that aren't chosen" do
      expect(comparer.unchosen).to be_a Array
    end
  end

  describe "#summary" do
    it "returns a summary of the comparer's results" do
      expect(comparer.summary).to be_a String
    end
  end 

  describe "#matched" do
    it "returns a list of criteria that were matched" do
      expect(comparer.matched).to eq($criteria)
    end
  end 

  describe "#analyze" do
    it "chooses the smallest number of records that meet all criteria" do
      @comparer.analyze
      expect(@comparer.chosen).to eq([$needed_record, $extra_record])
    end
  end  
end

shared_examples SizedRecordComparer do
  context "extends RecordComparer functionality" do
    describe "#reset" do
      it "also sets the minimum size to 1" do   
        comparer.reset
        expect(comparer.minimum_size).to eq(1)
      end
    end
  
    describe "#analyze" do
      it "also chooses random records until minimum size is reached" do
        expect(comparer).to receive(:supplement)
        comparer.analyze
      end
    end
  end
end