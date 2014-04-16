require "csv"

DATA_COLUMNS = 5.0

output_data = []

Dir.glob("/path/to/dir/*.csv") do |csv_file|
  results = CSV.read(csv_file)
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

CSV.open("result_with_many_failures.csv", "wb",
         {:force_quotes => false}) do |csv|
  output_data.each do |row|
    csv << row
  end
end
