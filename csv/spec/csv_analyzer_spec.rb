require 'rspec'
require 'csv_analyzer'

describe CSVAnalyzer do

  before(:each) do
    @analyzer = CSVAnalyzer.new
    @analyzer.addToCSVDataFromDir("./csv_sample_dir")
  end

  it "adds data from a CSV file" do
    expect(@analyzer.csv_data).not_to be_empty
  end

  it "gets a header row from a CSV file" do
    expect(@analyzer.getCSVHeaderRow).to eq ["something","something else","another something","HAS SOMETHING","HAS ANOTHER","HAS A THIRD","HAS FOURTH"]
  end

  it "counts columns" do
    expect(@analyzer.countColumns(/^HAS/)).to eq 4
    expect(@analyzer.countColumns(/^HAS SOMETHING$/)).to eq 1
  end

  it "can set ignored columns" do
    expect(@analyzer.ignored_column_count).to eq 0
    @analyzer.ignored_column_count = @analyzer.countColumns(/^HAS/)
    expect(@analyzer.ignored_column_count).to eq 4
  end

  it "sets the header row for output data" do
    expect(@analyzer.csv_output).to be_empty
    @analyzer.setOutputHeader(["one","two","buckle","my","shoe"])
    expect(@analyzer.csv_output[0]).to eq ["one","two","buckle","my","shoe"]
  end
  
end
