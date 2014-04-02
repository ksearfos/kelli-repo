require 'classes/RecordComparer'
require 'lib/OHmodule/OhioHealthUtilities'

module TestRunnerMixins
  
  module ComparerUtilities

    # ----- setup ----- #
    def set_up_comparer(messages, org_specific)
      criteria = get_criteria(messages)
      comparer_class = org_specific ? OrgSensitiveRecordComparer : RecordComparer
      @comparer = comparer_class.new(messages, criteria)  
    end
    
    # called by set_up_comparer
    def get_criteria(messages) 
      criteria = OhioHealthUtilities.get_field_values_at_runtime(@file_handler.records, @message_type, self.extra_criteria) 
      criteria.merge OhioHealthUtilties.instance_variable_get("@#{@message_type}").clone
    end
    
    # ----- output ----- # 
    def write_intermediate_results(outfile)
      @logger.add "Writing results to #{outfile}"
      write_file = File.open(outfile, "a+")  
      @comparer.chosen.each { |record| write_file.puts record.to_s }
      write_file.close  
    end

    def write_final_results
      @logger.section "Criteria checked:\n#{@comparer.show_criteria}"
      save_results_to_csv(@csv_file, @comparer.chosen) 
    end
  
  end
  
end