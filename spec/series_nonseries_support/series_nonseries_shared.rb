shared_examples "SeriesNonseriesSupport" do
  
  describe "#get_records_of_type" do
    it "finds all records of type" do
      results = { series:true, nonseries:false }
      should_pass_for_type(type, results) do
        series = SeriesNonseriesSupport.get_records_of_type(@records, type)
        series.include?(@series_record) 
      end        
    end
  end
  
  describe "#number_of_records_of_type" do
    it "counts the records of type" do
      results = { series:1, nonseries:3 }
      should_pass_for_type(type, results) { SeriesNonseriesSupport.number_of_records_of_type(@records, type) }      
    end
  end
  
  describe "#amount_that_fixes_proportion" do
    it "determines how many records of type must be added/removed for the proportion to be ideal" do
      results = { series:0, nonseries:46 }
      should_pass_for_type(type, results) { SeriesNonseriesSupport.amount_that_fixes_proportion(@records, type) }  
    end
  end
  
end