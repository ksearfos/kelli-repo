require "csv"

HEADER_ROW = 0

def countDataColumns(row)
  data_col_count = 0
  row.each do |col|
    data_col_count += 1 unless col =~ /^HAS /
  end
  data_col_count
end

output_data = []
first_time = true

Dir.glob("./CSV/*.csv") do |csv_file|
  results = CSV.read(csv_file)
  if first_time
    output_data << results[HEADER_ROW]
    DATA_COLUMNS = countDataColumns(results[HEADER_ROW])
    first_time = false
  end
  results.each do |result|
    result_columns = (result.size - DATA_COLUMNS)
    failures = 0.0
    result[DATA_COLUMNS..-1].each do |col|
      failures += 1 if col.upcase == "FAILED"
    end
    output_data << result if (failures / result_columns) >= 0.5
  end
end

CSV.open("results_with_many_failures.csv", "wb",
         {:force_quotes => false}) do |csv|
  output_data.each do |row|
    csv << row
  end
end
