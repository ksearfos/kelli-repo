module OHProcs
  
  SERIES_PROPORTION = 0.02   # 2% of records should be SERIES records
  SERIES_ENC = Proc.new{ |message| message[:PID].account_number[0] == 'A' }
  
  def self.series_or_nonseries( number_of_series, number_of_non )
    proportion = number_of_series / ( number_of_series + number_of_non ).to_f    # quotient is a Float if divisor is
    proportion < SERIES_PROPORTION ? :series : :nonseries
  end
  
  def self.sort_records( all_records )
    series = []
    nonseries = []
    all_records.each{ |record| SERIES_ENC.call(record) ? series << rec : nonseries << rec }
    [ series, nonseries ]
  end

  def self.pick_one_of_type( options, series_or_non )    
    series,nonseries = OHProcs.sort_records( options )
      
    if series.empty? || needed_record == :nonseries
      nonseries.first
    elsif nonseries.empty? || needed_record == :series
      series.first
    else  # should never get here, but that doesn't mean we won't!
      options.shuffle.first
    end
  end  
  
  def self.analyze_proportions( records, ideal_size )
    size = records.size
    records_needed = ideal_size - size   
    series_size = sort_records( records ).first.size
    
    series_needed = ideal_size * SERIES_PROPORTION - series_size 
    series_needed = 0 if series_needed < 0    # negative numbers don't make sense here   
    nonseries_needed = records_needed - series_needed
    
    [ series_needed, nonseries_needed ]
  end
end