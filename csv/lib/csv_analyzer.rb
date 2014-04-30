# This program takes a comma separated values file, or set of files,
# and parses it to analyze its contents.
#
# Author:: Tim Morgan (mailto:tmorgan@manifestcorp.com)
require 'csv'
require 'highline/import'

# This class provides methods necessary to parse throgh and analyze 
# comma separated values files.
class CSVAnalyzer
  
  HEADER_ROW = 0
  
  attr_reader :csv_data, :csv_output
  attr_accessor :ignored_column_count, :data_columns

  def initialize
    @csv_data = []
    @csv_output = []
    @ignored_column_count = 0
    @data_columns = 0
  end
  
  # regex param matches columns we ARE evaluating.
  def count_columns(regex)
    row = get_header_row
    row.count{ |col| col =~ regex }
  end

  # Add csv file contents from a directory to @csv_data, 
  # dir_name is relative to csv root folder by default.
  def add_rows_to_csv_data_from_dir(dir)
    Dir.glob("#{dir}/*.csv") do |csv_file|
      @csv_data += CSV.read(csv_file)
    end
  end

  def add_rows_to_csv_data_from_file(file)
    @csv_data += CSV.read(file)
  end

  # Get the header row from a csv data array.
  def get_header_row(csv_data_array=@csv_data)
    csv_data_array.first
  end

  def insert_output_header(header)
     @csv_output.insert(0, header)
   end

  def overwrite_output_header(header)
    @csv_output[HEADER_ROW] = header
  end

  def parse_csv_data(header, search_term, precision)
    @csv_data.each do |row|
      matches = 0.0
      unless row == header
        row[@ignored_column_count..-1].each { |col| matches += 1 if col == search_term }
      end
      @csv_output << row if (matches / @data_columns) >= precision
    end
    @csv_output
  end

  # Write @csv_output to a file, overwrites any existing file
  # with the same name.
  def export_csv(file_name)
    CSV.open(file_name, "wb", {:force_quotes => false}) do |csv|
      @csv_output.each { |row| csv << row }
    end
  end

end

# A menu for using the CSV Analyzer
analyzer = CSVAnalyzer.new

say("\nCSV Analyzer Menu")
loop do
  choose do |menu|
      
    menu.prompt = "Choose a task to perform..."

    menu.choice "Add rows from directory" do
      dir = ask("Enter a directory:") do |resp|
        resp.whitespace = :strip_and_collapse
      end
      say("Loading data from #{dir}...\n\n")
      analyzer.add_rows_to_csv_data_from_dir dir
    end
      
    menu.choice "Add rows from file" do
      file = ask("Enter a file:") do |resp|
        resp.whitespace = :strip_and_collapse
      end
      say("Loading data from #{file}...\n\n")
      analyzer.add_rows_to_csv_data_from_file file
    end
      
    menu.choices("Parse data", "Export data") do say("Not yet implemented...\n\n") end
    
    menu.choice "Quit" do exit end
      
  end
end

