require 'mixins/TestRunnerMixins'
require 'lib/OHmodule/OhioHealthUtilities'
require 'lib/hl7/HL7'
################# @outfile not currently used!!!!
################  @inputfile, @outputfile have very restricted uses... consider removing
class RecordComparerRunner
  include TestRunnerMixIn, OhioHealthUtilities, HL7CSV
  
  @extra_criteria = { sending_facility:"msh3" }   # why, yes, I *do* want class-level variables!
  
  def initialize( type, debugging, minimum_size )
    set_common_instance_variables( type, debugging )  
    @input_file_pattern = ( @debugging ? /^#{@message_type}_pre_\d/ : /^\w+_pre_\d+\.dat$/ )    
    @minimum_size = minimum_size
    finish_setup   # once this is done, the logger will be "turned on" and we will have our hl7 file list
    set_comparer_files
  end

  def run
    set_comparer_files
    compare_original_files
    compare_results_files
    remove_files( @tempfile )  
  end
      
  def compare_original_files
    hl7_files = get_files( @input_directory, @input_file_pattern )
    hl7_files.each{ |file| 
      run_first_pass( file )      
      prepare( @tempfile, @results_file_prefix + file )
      compare( true, false )
    } 
  end
  
  def compare_results_files
    result_files = get_files( @logger_directory, @results_file_prefix )
    result_files.each{ |file| run_first_pass( file ) }
    
    prepare( @tempfile, @csv_file )
    compare( true, true )
  end  
  
  def run_first_pass( file )
    prepare( file, @tempfile )
    compare( false, false )
  end
  
  def prepare( input_file, output_file )
    create_file_handler( input_file, FileHandling.max_records )
    raise HL7::FileError, "Could not create HL7::FileHandler from #{input_file}" if @file_handler.nil?
    
    set_comparer_IO( input_file, output_file )    
    set_criteria( @file_handler.records )
  end
  
  private  
  
  def compare( org_specific, final )
    args = [ @file_handler.records, @criteria ]
    args << minimum_number_of_results if final
    comparer = org_specific ? OrgSensitiveRecordComparer.new(*args) : RecordComparer.new(*args)
    comparer.analyze  
    
    log "Finished running record comparer", :child
    log comparer.summary, :child  
    final ? write_final_results( comparer ) : write_temporary_results( comparer )
  end

end
