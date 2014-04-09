# last tested 4/7
require 'lib/extended_base_classes'
require 'lib/HL7CSV'    # where row is defined

class RecordComparer
  
  attr_reader :records_and_criteria
  attr_writer :minimum_size, :records_to_avoid
  
  def initialize(records, criteria)
    @records_and_criteria = Hash.new_from_array(records, [])
    @criteria = criteria
    
    determine_record_criteria      # populates @records_and_criteria.values
    @records_and_criteria.freeze   # once set, this should never be changed!
    
    set_starting_values            # sets @used_records, @unused_records, @minimum_size, @records_to_avoid
    @matched_criteria = get_criteria
  end
  
  def analyze
    return unless @records_and_criteria.size > @minimum_size   # if we need all the records, we already have the "smallest number"
    remove_unwanted_records
    remove_records_with_duplicate_criteria
    remove_redundancies  
    supplement_chosen
  end

  # allow reset to re-analyze
  def reset
    set_starting_values
  end
  
  def chosen
    @used_records
  end  
  
  def summary
    "I have successfully matched #{matched.size} of #{@criteria.size} criteria, for a total of #{chosen.size} records."
  end
  
  def unmatched  
    unmatched = @criteria.keys - @matched_criteria
    unmatched.sort
  end
  
  def matched
    @matched_criteria.sort
  end
  
  private

  # called by initialize
  def determine_record_criteria
    @records_and_criteria.each_key { |record| @records_and_criteria[record] = passing_criteria(record) }
  end 

  # called by initialize
  def remove_records_with_duplicate_criteria
    criteria_to_record = @records_and_criteria.flip  # => [ [procname, record(s)] ]
    criteria_to_record.each_value do |records|
      next unless records.size > 1   # don't do anything with unique sets of criteria
      unchoose_all_but_one(records)
    end
  end

  # called by remove_records_with_duplicate_criteria
  def unchoose_all_but_one(records)
    records.shuffle!
    records.shift       # "choose" the first one by not un-choosing it
    unchoose(*records)   
  end
 
  # called by analyze
  def remove_redundancies
    rec_crit_array = @records_and_criteria.sort_by { |_,criteria| criteria.size }   # => [[rec1,crit1],[rec2,crit2]...]
    rec_crit_array.each do |record,_| 
      next unless @used_records.include?(record)
      unchoose(record) if is_redundant?(record)
    end
  end
  
  # called by analyze
  def remove_unwanted_records
    unwanted = @used_records.select { |record| exclude?(record) }
    unchoose(*unwanted)
  end
   
  # called by determine_record_criteria and criteria_matched_without_record
  def get_criteria(records = @records_and_criteria.keys)
    criteria = records.map { |record| @records_and_criteria[record] }
    criteria.flatten.uniq
  end 

  # called by determine_record_criteria  
  def passing_criteria(record)
    @criteria.select { |_,proc| proc.call(record) }.keys
  end

  # called by remove_records_with_duplicate_criteria
  def unchoose(*records)
    records.each do |record|
      raise "Cannot unchoose a #{record.class}!" if !record.is_a? HL7::Message
      @unused_records << record
      @used_records.delete(record)
    end
    @unused_records.uniq!
  end

  # called by supplement_chosen
  def choose(*records)
    records.each do |record|
      @unused_records.delete(record)
      @used_records << record
    end
    @used_records.uniq!
  end
    
  # called by remove_redundancies
  def is_redundant?(record)
    criteria_matched_without_record(record).size == @matched_criteria.size
  end 
   
   # called by is_redundant?    
  def criteria_matched_without_record(record)
    used_records = @used_records.clone  # don't want to actually alter instance variable
    used_records.delete(record)
    get_criteria(used_records)
  end 
  
  # called by analyze
  def supplement_chosen
    choose_random_records(amount_to_reach_minimum_size)
  end
  
  # called by supplement_chosen
  def choose_random_records(amount, pool_of_records = @unused_records.clone)  
    chosen = pool_of_records.shuffle.take(amount)
    choose(*chosen)
  end
  
  # called by initialize, reset
  def set_starting_values
    @used_records = @records_and_criteria.keys
    @unused_records = []
    @minimum_size = 1        # smallest number of records to return
    @records_to_avoid = []   # records to exclude from search results
  end
  
  def chose_enough?
    @used_records.size >= @minimum_size
  end
  
  def records_left_to_take?
    @used_records.size < @records_and_criteria.size
  end

  def amount_to_reach_minimum_size
    if chose_enough? || !records_left_to_take? then 0
    else @minimum_size - @used_records.size
    end
  end
  
  def exclude?(record)
    @records_to_avoid.include?(record.to_row)
  end
end  