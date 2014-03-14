# == PID tests

shared_examples "Rad/ADT PID segment" do |pid|
  it "has a valid race",
  :pattern => "a human race" do
    pid.race.should match /^(\d{1})?$/
  end

  it "has a Country Code that matches the Address",
  :pattern => "" do
    unless pid.country_code.empty?
      country = pid.address[/\^\w{2}\^/]
      pid.country_code.should eq country
    end
  end

  it "has a valid Language",
  :pattern => "a three character language code" do
    pid.primary_language.should match /^([a-zA-Z]{3})?$/
  end

  it "has a valid Marital Status",
  :pattern => "a single character" do
    pid.marital_status.should match /^[A-Z]?$/
  end
end

# == PV1 tests

shared_examples "Lab/ADT PV1 segment" do |pv1|
  it "has the same Attending and Referring Doctor",
  :pattern => 'fields should match unless Referring Doctor field is empty' do
    unless pv1.referring_doctor.empty?
      pv1.referring_doctor.should eq pv1.attending_doctor
    end
  end
end
