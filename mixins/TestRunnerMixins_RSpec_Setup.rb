require 'rspec'
require 'HL7CSV'

module TestRunnerMixins
  
  module RSpecSetup

    def set_up_rspec_for_file
      $flagged = {}     # start with a clean hash
      redirect_stdout("#{result_file_prefix}_rspec.log") 
    end
    
    def run_rspec
      @logger.section "Testing records..."
      RSpec::Core::Runner.run ["spec/conversion/#{@message_type}_spec.rb"]
    end
      
    def save_flagged_records(csv_file)
      csv_array = compile_flagged_records_into_array
      HL7CSV.make_spreadsheet_from_array(csv_file,csv_array)
      @logger.info "See #{csv_file}"
    end
    
    def compile_flagged_records_into_array
      spreadsheet_array = [header_row]    # an array of arrays
      $flagged.each_pair do |message,errors|
        row_array = message.to_row + errors_in_row(errors)
        spreadsheet_array << row_array
      end    
      spreadsheet_array
    end

  	def header_row
  	  record_header = HL7CSV.get_header(@message_type)
  	  errors_header = extract_errors.map { |error| error.upcase }
      record_header + errors_header
    end

  	def extract_errors
      $flagged.values.flatten.uniq
    end
  
  	def errors_in_row(errors_for_message)
      values = []
      extract_errors.each do |error|    # I chose not to use the ternary operator purely for readability
        if errors_for_message.include?(error) then values << "FAILED"
        else values << "PASSED"
        end
      end    
      values
    end
  
  end
  
end