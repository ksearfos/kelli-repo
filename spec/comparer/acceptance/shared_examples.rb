shared_examples "properly-working comparer" do
  it "finds all records from all files" do
    expect(results[:number_of_records]).to eq(number_of_records)
  end
  
  it "finds a small subset of records" do
    lower_bound = subset_size * 0.90   # size - 10%
    upper_bound = subset_size * 1.10   # size + 10%
    expect(results[:subset_size]).to be_between(lower_bound, upper_bound)
  end
  
  it "matches all criteria matched by the full record set" do
    expect(results[:matched_criteria]).to eq(matched_criteria)
  end
end
