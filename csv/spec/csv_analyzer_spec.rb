require 'rspec'
require 'csv_analyzer'

describe CSVAnalyzer do

  before(:all) do
    @analyzer = CSVAnalyzer.new
    @analyzer.addToCSVDataFromDir("./csv_sample_dir")
  end

  it "adds data from a CSV file" do
    expect(@analyzer.csv_data).not_to be_empty
  end

  it "gets a header row from a CSV file" do
    expect(@analyzer.getCSVHeaderRow).to eq ["something","something else","another something","HAS SOMETHING","HAS ANOTHER","HAS A THIRD","HAS FOURTH"]
  end

  it "counts columns to ignore" do
    expect(@analyzer.countIgnoredColumns(/^HAS/)).to eq 4
    expect(@analyzer.countIgnoredColumns(/^HAS SOMETHING$/)).to eq 1
  end
  
end
