require 'working_folder/test_runner_helper'

class ComparisonRunner
  MAX_RECS = 1000
  attr_reader :infile, :outfile, :record_count 
  
  def initialize(infile, outfile)
    @infile = infile
    @outfile = outfile
    @record_count = 0
  end
  
  def compare
    old_compare
    [@criteria, @subset]
  end
  
  private
  
  def old_compare   
    file_handler = nil    # reset  
    file_handler = get_records(@infile, MAX_RECS)   
    
    if file_handler.nil?   # will be nil if file was empty
      remove_files([@infile])
    else        
      begin
        $logger.info "Found #{file_handler.size} record(s)\n" 
        $logger.info "Comparing records..."    
        
        @record_count += file_handler.records.size
        @criteria, @subset = run_record_comparer( @outfile, file_handler.records, false, false )        
        file_handler.next
      end until file_handler.records.empty?
    end 
  end
end