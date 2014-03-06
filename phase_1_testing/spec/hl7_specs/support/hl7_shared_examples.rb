# == General tests

shared_examples "General" do |message|
  it "has only one PID per message", :pattern => '' do
    message.children[:PID].size.should == 1
  end
  
  it "has only one PV1 per message", :pattern => '' do
    message.children[:PV1].size.should == 1
  end
end

# == MSH tests

shared_examples "MSH segment" do |msh|

  it "has a valid Message Control ID",
  :pattern => 'if MGH P, otherwise T' do
    if msh.e3 =~ /MGH/
      msh.e10.should match /^P$/
    else
      msh.e10.should match /^T$/
    end
  end
end

shared_examples "Lab/Rad MSH segment" do |msh|
  it "has MSH segments with the correct Event format",
  :pattern => 'ORU^R01' do
    msh.e8.should match /^ORU\^R01$/
  end
end

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

# == OBR tests

shared_examples "OBR segment" do |obr, message|
  it "has Control Code containing only letters, numbers, and spaces", 
  :pattern => 'one or more characters and/or numbers with spaces allowed' do
    obr.filler_order_number.should match /^[A-Za-z0-9][A-Za-z0-9 ]*/
  end
      
  # Consider adding test for provider title e.g. MD, DO, etc...
  it "has Ordering Provider in the correct format", 
  :pattern => 'an optional capital letter followed by numbers, lastname, firstname, optional middle initial, final field ends with PROV' do
    obr.ordering_provider.should match /^[A-Z]?[0-9]+\^[A-Z a-z\-]+\^[A-Z a-z]+\^[A-Z]?\^/
    obr.ordering_provider.should match /\^\w+PROV$/
  end
  
  # Make sure all possible status markers are in regex
  it "has Result Status in the correct format", 
  :pattern => 'any single letter in [DFNOSWPXCRUI]' do
    obr.result_status.should match /^[DFNOSWPCXRUI]$/
  end

  it "has Date/Time values in the correct format", 
  :pattern => 'a timestamp in yyyyMMddHHmm format' do
    # yyyyMMddHHmm
    obr.observation_date.should match /^(19|20)\d\d(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])((0|1)[0-9]|2[0-3])(0[0-9]|[1-5][0-9])$/
  end

  it "has Results Status Date that is the same as the Observation Date", 
  :pattern => 'matching dates' do
    obr.results_status_change_date.should eq obr.observation_date
  end

end

# == OBX tests

shared_examples "OBX child" do |obx, value_type|
  
end

# == PID tests

shared_examples "PID segment" do |pid|

  it "has Patient Name in the correct format", 
  :pattern => 'lastname, firstname, optional initial, JR. or SR. or Roman Numeral' do
    # Lastname^Firstname^I^JR.|SR.|RomanNumeral
    pid.patient_name.should match /^\w+([- ]{1}\w+)*\^\w+(\^|\^[A-Z])?(\^((JR|SR)\.|((II|III|IV|V))))?$/
  end

  it "has PID segments with the correct Patient ID format",
  :pattern => 'begins with digits and ends with characters followed by "01"' do
    pid.patient_id_list.should match /^\d*\^/
    pid.patient_id_list.should match /\^\w+01$/
  end

  it "has Visit ID in the correct format", 
  :pattern => 'begins with an optional capital letter followed by numbers and ends with characters followed by "ACC"' do
    pid.account_number.should match /^[A-Z]?\d+\^/
    pid.account_number.should match /\^\w+ACC$/
  end

  it "has Date of Birth in the correct format",
  :pattern => 'year month day (yyyyMMdd)' do
    # yyyyMMdd
    pid.patient_dob.should match /^(19|20)\d\d(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])$/
  end

  it "has Sex in the correct format", :pattern => 'one of [FMOUANC]' do
    # F|M|O|U|A|N|C
    pid.admin_sex.should match /^[FMOUANC]$/
  end

  it "has SSN in the correct format", :pattern => 'a social security number without dashes' do
    pid.social_security_num.should match /^\d{9}$/
  end
end

shared_examples "Rad/ADT PID segment" do |pid|
  it "has a valid race",
  :pattern => "a human race" do
    pid.race.should match /^(\d{4}-\d{1})?$/
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

shared_examples "PV1 segment" do |pv1, pid|
  it "has Visit ID that matches PID Visit ID", 
  :pattern => 'Visit ID and PID Visit ID fields should match' do
    pv1.visit_number.should eq pid.account_number 
  end
end

shared_examples "Lab/ADT PV1 segment" do |pv1|
  it "has the same Attending and Referring Doctor",
  :pattern => 'fields should match unless Referring Doctor field is empty' do
    unless pv1.referring_doctor.empty?
      pv1.referring_doctor.should eq pv1.attending_doctor
    end
  end
end
