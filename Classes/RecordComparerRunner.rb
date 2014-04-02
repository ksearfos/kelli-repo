require 'mixins/TestRunnerMixin'
require 'mixins/ComparerMixin'

class RecordComparerRunner
  include TestRunnerMixIn, ComparerMixIn
  
  @extra_criteria = { sending_facility:"msh3" }   # why, yes, I *do* want class-level variables!
  @results_file_prefix = "#{@logger.directory}/results"
  
  def initialize(type, debugging, minimum_size)
    set_common_instance_variables(type, debugging)    
    @minimum_size = minimum_size
    @input_file_pattern = @debugging ? /\A#{@message_type}_pre_\d/ : /\w+_pre_\d+\.dat/
    @csv_file = "#{INFO_FILE_PREFIX}_selected_#{@message_type}_records.csv"
    @comparer = nil
  end

  def run
    compare_original_files
    compare_results_files 
    @logger.close 
  end

  def supplement_existing
    hl7_files = get_files(@input_directory, @input_file_pattern).shuffle
    @csv_file = "#{INFO_FILE_PREFIX}_supplemental_#{@message_type}_records.csv"
    @logger.info "Grabbing #{@minimum_size} records at random"
    file_handler = create_file_handler(hl7_files.first, @minimum_size)
    save_results_to_csv(file_handler.records)
    @logger.close
  end
  
  private
  
  # ----- top-level delegation: looping through file trees ----- #    
  def compare_original_files
    hl7_files = get_files(@input_directory, @input_file_pattern)    
    hl7_files.each do |file| 
      file_handler = create_file_handler(file)
      do_in_increments(file_handler) { gather_temp_results(file_handler.records) }   # repeat for sets of 10,000 records
      gather_final_results("#{@results_file_prefix}_#{File.basename(file)}")   
    end 
  end
  
  def compare_results_files
    result_files = get_files(@logger_directory, @results_file_prefix)
    result_files.each do |file| 
      file_handler = create_file_handler(file)
      gather_temp_results(file_handler.records)
      remove_file(file) unless @debugging
    end
    gather_final_results
  end  
  
  # ----- mid-level delegation: comparing groups of records ----- #
  def gather_temp_results(records)
    set_up_comparer(records, false)   # sets @comparer
    compare
    write_intermediate_results(@tempfile)
  end
  
  def gather_final_results(outfile = "")
    file_handler = create_file_handler(@tempfile)
    set_up_comparer(file_handler.records, true)   # sets @comparer 
    outfile.empty? ? do_final_comparison : do_intermediate_comparison(outfile)
    remove_file(@tempfile)
  end

  # ----- bottom-level delegation: sectionalizing for second pass ----- #
  def do_intermediate_comparison(outfile)
    compare
    write_intermediate_results(outfile)
  end
  
  def do_final_comparison
    @comparer.minimum_size = @minumum_size
    compare  
    write_final_results 
  end
  
  # ----- core functionality ----- #  
  def compare
    @logger.section "Beginning comparison..."
    @comparer.analyze 
    @logger.add @comparer.summary      
  end
  
  # ----- string formation ----- #
  
  
end
