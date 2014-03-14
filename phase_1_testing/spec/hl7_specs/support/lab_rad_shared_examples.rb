# == MSH tests

shared_examples "Lab/Rad MSH segment" do |msh|
  it "has MSH segments with the correct Event format",
  :pattern => 'ORU^R01' do
    msh.e8.should match /^ORU\^R01$/
  end
end
