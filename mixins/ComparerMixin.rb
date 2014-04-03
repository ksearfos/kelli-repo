require 'classes/RecordComparer'
require 'classes/OrgSensitiveRecordComparer'
require 'lib/OHmodule/OhioHealthUtilities'
require 'lib/HL7CSV'

module ComparerMixIn

    # ----- setup ----- #
    # creates RecordComparer or OrgSensitiveRecordComparer object
    # takes an array of strings, and a boolean
    # returns nothing, but sets @comparer
    def set_up_comparer(messages, org_specific)
      criteria_args = [messages, @message_type]
      criteria_args << self.class.extra_criteria if self.class.instance_variable_defined?(:@extra_criteria)
      criteria = OhioHealthUtilities.get_all_criteria_for_type(*criteria_args)
      comparer_class = org_specific ? OrgSensitiveRecordComparer : RecordComparer
      @comparer = comparer_class.new(messages, criteria)  
    end
    
    # ----- output ----- # 
    # writes results to a text file
    # calls File#open and merely adds logging
    def write_intermediate_results(outfile)
      @logger.child "Writing results to #{outfile}"
      write_file = File.open(outfile, "a+")  
      @comparer.chosen.each { |record| write_file.puts record.to_s }
      write_file.close  
    end

    # writes results to a csv file
    # calls HL7CSV#records_to_spreadsheet and merely adds logging 
    def write_final_results
      @logger.section "Criteria checked:\n#{@comparer.show_criteria}"
      HL7CSV.records_to_spreadsheet(@csv_file, @comparer.chosen)
      @logger.info "See #{@csv_file}"
    end
  
  end