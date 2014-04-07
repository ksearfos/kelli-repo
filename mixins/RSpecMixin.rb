# last tested 4/7
require 'rspec'
require 'HL7CSV'

module RSpecMixIn
  
  # the ONLY module-level method
  def self.extract_errors
    $flagged.values.flatten.uniq
  end

  # now, onto the instance methods
  # creates the global variable $flagged, for use in rspec, and redirects stdout to point to the new rspec.log file
  def set_up_rspec
    $flagged = {}     # start with a clean hash
    redirect_stdout("#{result_file_prefix}_rspec.log") 
  end
    
  # launches an instance of the RSpec::Core::Runner, and adds logging
  def run_rspec
    @logger.parent "Testing records..."
    RSpec::Core::Runner.run ["spec/conversion/#{@message_type}_spec.rb"]
  end

  # saves all records in $flagged to the specified file
  # takes a String    
  # uses the subroutine compile_flagged_records_into_array and HL7CSV.make_spreadsheet_from_array  
  def save_flagged_records(csv_file)
    csv_array = compile_flagged_records_into_array
    HL7CSV.make_spreadsheet_from_array(csv_file, csv_array)
    @logger.info "See #{csv_file}"
  end
  
  # creates an array of the flagged messages matching the form [[row1], [row2], [row3], ...]
  # at this point, $flagged contains HL7::Message objects pointing to Arrays of error Strings
  # each row is itself an Array
  # the first 5 or 6 values are record information, the last however-many are either PASSED or FAILED 
  def compile_flagged_records_into_array
    spreadsheet_array = [header_row]    # an array of arrays
    $flagged.each_pair do |message,errors|
      row_array = message.to_row + errors_in_row(errors)
      spreadsheet_array << row_array
    end    
    spreadsheet_array
  end

  # called by compile_flagged_records_into_array
  # creates the header row by taking the pre-defined message info headers and adding exception descriptions
  # returns an array like [INFO1, INFO2, INFO3, ERROR1, ERROR2]
  def header_row
    record_header = HL7CSV.get_header(@message_type)
    errors_header = RSpecMixIn.extract_errors.map { |error| error.upcase }
    record_header + errors_header
  end
  
  # called by compile_flagged_records_into_array
  # checks each error found against the errors given, mapping to a "PASSED" or "FAILED" value
  #+ FAILED if the error is in the list given, PASSED otherwise
  # returns an array of PASSED and FAILED
  def errors_in_row(errors_for_message)
    values = RSpecMixIn.extract_errors.collect { |error| errors_for_message.include?(error) }  
    values.map { |true_false| true_false ? "FAILED" : "PASSED" }
  end
  
end
