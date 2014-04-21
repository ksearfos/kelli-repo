require 'rspec'
require 'csv_analyzer'

describe CSVAnalyzer do

  it "gets data from a CSV file" do
    analyzer = CSVAnalyzer.new
    analyzer.addToCSVDataFromDir("./csv_sample_dir")
    expect(analyzer.csv_data).not_to be_empty
  end
  
end
