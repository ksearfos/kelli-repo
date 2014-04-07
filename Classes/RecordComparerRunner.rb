require 'classes/TestRunner'
require 'mixins/ComparerMixin'

class RecordComparerRunner < TestRunner
  include ComparerMixIn
  
  # this could very easily change for a subclass
  @extra_criteria = { sending_facility:"msh3" }
  
  def initialize(type, debugging, minimum_size)
    super(type, debugging)    
    @minimum_size = minimum_size
    @input_file_pattern = /#{@message_type}_#{PRE_FILE_REGEX}/
    @results_file = "#{@logger.directory}/#{RESULTS_FILENAME}"
    @temp_file = "#{@logger.directory}/#{TEMP_FILENAME}"
    @csv_file = ""
    @comparer = nil
  end

  def run
    @csv_file = construct_csv_filename("selected")
    compare_original_files
    compare_results_files  
  end

  def supplement_existing
    @csv_file = construct_csv_filename("supplemental")
    @logger.info "Selecting #{@minimum_size} records at random"
    records = get_random_records.take(@minimum_size)
    save_results_to_csv(records)
  end
  
  private
  
  # ----- top-level delegation: looping through file trees ----- #    
  def compare_original_files    
    get_hl7_files.each do |file| 
      gather_temp_results(file)
      gather_final_results("#{@results_file}_#{File.basename(file)}")   
    end 
  end
  
  def compare_results_files
    result_files = get_files(@logger.directory, /\A#{RESULTS_FILENAME}_/)
    result_files.each do |file| 
      gather_temp_results(file)
      remove_file(file) unless @debugging
    end
    gather_final_results
  end  
  
  # ----- mid-level delegation: comparing groups of records ----- #
  def gather_temp_results(infile)
    file_handler = create_file_handler(infile)
    file_handler.do_in_increments do |set_of_records| 
      set_up_comparer(set_of_records)   # sets @comparer
      do_intermediate_comparison(@temp_file)
    end
  end
  
  def gather_final_results(outfile = "")
    file_handler = create_file_handler(@temp_file)
    set_up_org_sensitive_comparer(file_handler.records)   # sets @comparer     
    outfile.empty? ? do_final_comparison : do_intermediate_comparison(outfile)
    remove_file(@temp_file)
  end

  # ----- bottom-level delegation: sectionalizing for second pass ----- #
  def do_intermediate_comparison(outfile)
    compare
    write_intermediate_results(outfile)
  end
  
  def do_final_comparison
    @comparer.minimum_size = @minimum_size
    compare  
    write_final_results 
  end
  
  # ----- core functionality ----- #  
  def compare
    @logger.parent "Beginning comparison..."
    @comparer.analyze 
    @logger.child @comparer.summary      
  end
  
  def get_random_records
    files = get_hl7_files
    records = []
    until records.size >= @minimum_size   # looping, just in case we need more records than 1 file has
      file_handler = create_file_handler(files.shift)
      records += file_handler.records
    end
    records
  end
  
  # ----- string formation ----- #
  def construct_csv_filename(detail)
    "#{@logger.directory}/#{@timestamp}_#{detail}_#{@message_type}_records.csv"
  end  
  
end
