require 'lib/RecordComparer'
require 'lib/OHmodule/OhioHealthUtilities'
require 'lib/HL7CSV'

module TestRunnerMixins
  
  module ComparerSetup   # adds @tempfile, @result_file_prefix, @csv_file, @infile, @outfile, @criteria
  
    def set_comparer_files
      @tempfile = @results_file_prefix + "temp_results"
      @result_file_prefix = "#{Logging.logging_directory}/results_"
      @csv_file = "#{Logging.logging_directory}/flagged_#{@message_type}_records.csv"
    end
  
    def set_comparer_IO( infile, outfile )
      @infile = infile
      @outfile = outfile 
    end

    def set_criteria( messages ) 
      @criteria = OhioHealthUtilties.instance_variable_get( "@#{@message_type}" ).clone
      @criteria.merge! get_field_values_at_runtime( @file_handler.records, @message_type ) 
      @criteria.merge! get_field_values_at_runtime( @file_handler.records, @message_type, self.extra_criteria )
    end
     
    def write_temporary_results( comparer )
      write_file = File.open( @tempfile, "a+" )  
      @comparer.chosen.each{ |record| write_file.puts record.to_s }
      write_file.close  
    end

    def write_final_results( comparer )
      log "Criteria checked:\n" + comparer.show_criteria
      save_results_to_csv( @csv_file, comparer.chosen ) 
    end
  
  end
  
end