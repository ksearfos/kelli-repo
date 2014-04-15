shared_examples "RecordComparer" do
  before(:each) do
    mock_list = double("mock_list")
    mock_list.stub(:find_redundancies) { [$redundant_record, $duplicate_record] } 
    mock_list.stub(:maps) { $all_records }
    mock_list.stub(:matched_criteria) { $criteria }
    @comparer = RecordComparer.new(mock_list)
  end
    
  it "has a list of record-criteria maps" do
    expect(@comparer).to respond_to :list_of_maps
  end
  
  describe "#reset" do
    it "chooses all records" do   
      @comparer.reset
      expect(@comparer.chosen.size).to eq(@comparer.list_of_maps.maps.size)
    end
  end 
  
  describe "#chosen" do    
    it "returns a list of the records chosen" do
      expect(@comparer.chosen).to be_a Array
    end
  end

  describe "#unchosen" do    
    it "returns a list of the records that aren't chosen" do
      expect(@comparer.unchosen).to be_a Array
    end
  end

  describe "#summary" do
    it "returns a summary of the comparer's results" do
      expect(@comparer.summary).to be_a String
    end
  end 

  describe "#matched" do
    it "returns a list of criteria that were matched" do
      expect(@comparer.matched).to eq($criteria)
    end
  end 
  
  describe "#analyze" do
    it "chooses the smallest number of records that meet all criteria" do
      @comparer.analyze
      expect(@comparer.chosen).to eq([$needed_record, $extra_record])
    end
  end

end