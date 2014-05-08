module ComparisonResult
  class << self
    attr_accessor :record_count, :criteria_count, :subset_record_counts, :matched_criteria_counts
  end
  
  @record_count = 0
  @criteria_count = 0
  @subset_record_counts = []
  @matched_criteria_counts = []
  
  # convenience methods for the Array variables, for cases when there is only one element
  # these mimic the naming of the single-count variables for consistency
  def self.subset_record_count
    subset_record_counts.first
  end
  
  def self.matched_criteria_count
    matched_criteria_counts.first
  end
  
  def self.to_hash
    { record_count: @record_count,
      criteria_count: @criteria_count,
      matched_criteria: matched_criteria_count,
      subset_size: subset_record_count
    }
  end
  
  def self.reset
    set_counts(0, 0, [], [])
  end
  
  def self.set_counts(records, criteria, subsets, matched)
    @record_count = records
    @criteria_count = criteria
    @subset_record_counts = subsets
    @matched_criteria_counts = matched  
  end
end