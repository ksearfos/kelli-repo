# == MSH tests

shared_examples "Lab/ADT MSH segment" do |msh|
  it "has the correct Processing ID",
  :pattern => 'if MGH 2.3, otherwise 2.4' do
    if msh.e3 =~ /MGH/
      msh.e11.should eq "2.3"
    else
      msh.e11.should eq "2.4"
    end
  end
end
