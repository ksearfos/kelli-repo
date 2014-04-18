require "csv"

HEADER_ROW = 0

def countDataColumns(row) do
  data_col_count = 0
  row.each do |col|
    data_col_count += 1 unless col =~ /^HAS /
  end
end

output_data = []

Dir.glob("/path/to/dir/*.csv") do |csv_file|
  results = CSV.read(csv_file)
  DATA_COLUMNS = countDataColumns(results[HEADER_ROW])
  results.each do |result|
    result_columns = (result.size - DATA_COLUMNS)
    failures = 0
    failures += result[DATA_COLUMNS..-1].each do |col|
      if col.upcase == "FAILED"
        1
      else
        0
      end
    end
    output_data += result if (failures / result_columns) >= 0.5
  end
end

CSV.open("results_with_many_failures.csv", "wb",
         {:force_quotes => false}) do |csv|
  output_data.each do |row|
    csv << row
  end
end
