require 'rspec'
require 'csv_analyzer'

describe CSVAnalyzer do

  before(:each) do
    @analyzer = CSVAnalyzer.new
    @analyzer.addToCSVDataFromDir("./csv_sample_dir/input")
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

  it "does not overwrite the current header row by default" do
    @analyzer.csv_output[0] = %w(1 2 3 PASSED PASSED PASSED PASSED)
    @analyzer.setOutputHeader(%w(first second third HAS\ ONE HAS\ TWO HAS\ THREE))
    expect(@analyzer.csv_output.size).to eq 2
    expect(@analyzer.getCSVHeaderRow(@analyzer.csv_output)).to eq ["first", "second", "third", "HAS ONE", "HAS TWO", "HAS THREE"]
  end

  it "overwrites the current header if asked to" do
    @analyzer.setOutputHeader(["one","two","buckle","my","shoe"])
    expect(@analyzer.csv_output[0]).to eq ["one","two","buckle","my","shoe"]
    @analyzer.setOutputHeader(["three","four","shut","the","door"], true)
    expect(@analyzer.csv_output.size).to eq 1
    expect(@analyzer.csv_output[0]).to eq ["three","four","shut","the","door"]
  end

  it "adds desired rows to csv_output" do
    header = @analyzer.getCSVHeaderRow
    @analyzer.data_columns = @analyzer.countColumns(/^HAS/)
    @analyzer.parseCSVData(header, "FAILED", 0.5)
    expect(@analyzer.csv_output.size).to eq 2
  end

  it "exports data to a csv file" do
    FileUtils.mkdir('./csv_sample_dir/output')
    expect(Dir['./csv_sample_dir/output/*']).to be_empty
    header = @analyzer.getCSVHeaderRow
    @analyzer.data_columns = @analyzer.countColumns(/^HAS/)
    @analyzer.parseCSVData(header, "FAILED", 0.5)
    @analyzer.exportCSV('./csv_sample_dir/output/spec_out.csv')
    expect(Dir['./csv_sample_dir/output/*.csv'].size).to eq 1
    FileUtils.rm_rf('./csv_sample_dir/output')
  end
  
end
