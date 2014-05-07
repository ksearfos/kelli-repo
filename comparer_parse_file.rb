require 'working_folder/test_runner_helper'

class ComparerParseFile
dt = Time.now.strftime "%H%M_%m-%d-%Y"      # HHMM_MM-DD-YYYY
TESTING = true  # make some changes if this is being run for testing
FTP = TESTING ? "C:/Users/Owner/Documents/script_input" : "d:/FTP"
LOG_DIR = "#{FTP}/logs"
PFX = LOG_DIR + "/#{dt}_"
LOG_FILE = PFX + "comparer_parse_testrunner.log"
MAX_RECS = 10000

def initialize
  
end

def run_comparison(type)
  file_pattern = TESTING ? /^#{type}_\w+/ : /^\w+_pre_\d+\.dat$/
  my_results = { :number_of_records => 0, :matched_criteria => 0, :subset_size => 0 }
  
# create the directory, if needed
`mkdir "#{LOG_DIR}"` unless File.exists?( LOG_DIR )

# set up - create logger and read in records from files
$logger = set_up_logger( LOG_FILE )
$logger.info "Checking #{FTP} for files..."

# find files, store in hl7_files with full pathname
hl7_files = Dir.entries( FTP ).select{ |f| File.file?("#{FTP}/#{f}") && f =~ file_pattern }

if hl7_files.empty?
  $logger.info "No new files found.\n"
else
  $logger.info "Found #{hl7_files.size} new file(s)\n"
  until hl7_files.empty?   # I am hoping that doing it this way will clear up memory as we go along
    fname = hl7_files.shift
    file = "#{FTP}/#{fname}"
    outfile = LOG_DIR + "/results_#{fname}"
    tmp = PFX + "temp_results"
    file_handler = nil    # reset
    
    file_handler = get_records( file, MAX_RECS )    
    if file_handler.nil?   # will be nil if file was empty
      remove_files( [file] )   # remove even if we are testing! it's empty!!
    else   
      begin
        $logger.info "Found #{file_handler.size} record(s)\n" 
        $logger.info "Comparing records..."    
        results[:number_of_records] += file_handler.size  #NEW
        run_record_comparer( tmp, file_handler.records, false, false )
        file_handler.next     # get the next however-many records -- @records will be empty if we got them all
      end until file_handler.records.empty?

      tmp_file_handler = get_records( tmp )
      $logger.info "Found #{tmp_file_handler.size} record(s)\n" 
      $logger.info "Comparing records..."       
      criteria, subset = run_record_comparer( outfile, tmp_file_handler.records, false, true )
      my_results[:matched_criteria] += criteria  # NEW
      my_results[:subset_size] += subset   # NEW
      remove_files( [tmp] )  
    end
  end  
end
end
$logger.info "Exiting..."
$logger.close
my_results  # NEW
end