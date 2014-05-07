require 'comparer/spec_helper'
require 'comparer/acceptance/shared_examples'
require 'working_folder/get_record_subset'

describe "parse file" do
  before(:all) do
    @input_dir = "C:/Users/Owner/Documents/Code/git/ohioHealth-phase1/spec/comparer/test_data"
  end
  
  context "when comparing rad records" do
    it_behaves_like "properly-working comparer" do
      let(:results) { run(:rad, @input_dir) }
      let(:number_of_records) {100}
      let(:matched_criteria) {86}   # of 103
      let(:subset_size) {69}
    end
  end
  
  context "when comparing encounter records" do
    it_behaves_like "properly-working comparer" do
      let(:results) { run(:enc, @input_dir) }
      let(:number_of_records) {500}
      let(:matched_criteria) {86}   # of 99
      let(:subset_size) {49}
    end  
  end
  
  context "when comparing lab records" do
    it_behaves_like "properly-working comparer" do
      let(:results) { run(:lab, @input_dir) }
      let(:number_of_records) {1005}
      let(:matched_criteria) {496}   # of 103
      let(:subset_size) {261}
    end
  end
end
