# == shared among all record types
shared_examples "every record" do 
  context "the patient" do   # PID segment
    it "has a valid MRN", :pattern => "numbers, ending with (something)01" do
      logic = Proc.new{ |msg|
        ptid = msg[:PID].field(:patient_id)
        ptid.first !~ /\D/ && ptid.last =~ /\w+01$/
      }
      @failed = pass?( messages, logic )
      @failed.should be_empty
    end

    it "has the correct PID indicator for the registering hospital" do
      logic = Proc.new{ |msg| 
        msh = msg.header
        hospital = msh[3]
        accn = msg[:PID].field(:account_number).first
        if hospital == "GMH"
          accn =~ /^(A|V)\d+/
        elsif hospital == "DMH"
          accn =~ /^B\d+/
        elsif hospital == "DH"
          accn =~ /^D\d+$/
        elsif hospital == "MGH"
          accn =~ /^MG\d+/
        elsif hospital == "RMH" || hospital == "GMC"
          accn =~ /^\d+/
      }
      @failed = pass?( messages, logic )
      @failed.should be_empty
    end
  
    it "has a real name", :pattern => "JR/SR ends with a period" do
      logic = Proc.new{ |msg|
        name = msg[:PID].field(:patient_name)
        sfx = name[4]
        ok = HL7.is_name? name.to_s
        sfx =~ /[JjSs][Rr]/ ? ok && sfx[-1] == '.' : ok
      }
      @failed = pass?( messages, logic )
      @failed.should be_empty
    end

    it "has a birthdate" do
      logic = Proc.new{ |msg| HL7.is_date? msg[:PID].dob }
      @failed = pass?( messages, logic )
      @failed.should be_empty
    end

    list = HL7::SEXES
    it "has a sex", :pattern => "one of #{list.join(', ')}" do
      logic = Proc.new{ |msg| list.include? msg[:PID].sex }
      @failed = pass?( messages, logic )
      @failed.should be_empty
    end

    it "has a SSN", :pattern => "9 digits without dashes" do
      logic = Proc.new{ |msg| msg[:PID].ssn =~ /^\d{9}$/ }
      @failed = pass?( messages, logic )
      @failed.should be_empty
    end  
  end
  
  context "the patient and encounter both" do
    # PID - account number and PV1 - visit number are the same thing, except
    #+ the PID verion might add a bunch of empty components and (something)ACC
    it "have the same account number", :pattern => "an optional capital letter and numbers" do
      logic = Proc.new{ |msg|
        beg = /^[A-Z]?\d+/ 
        acct = msg[:PID].field(:account_number).first
        visit = msg[:PV1].field(:visit_number) 
        visit.nil? ? acct =~ beg : acct =~ beg && acct == visit.first
      }
      @failed = pass?( messages, logic )
      @failed.should be_empty
    end
  end
  
  context "the encounter" do   # PV1 segment
    it "has a patient type", :pattern => "one or two digits" do
      logic = Proc.new{ |msg| 
        pv1 = msg[:PV1]
        pv1[18] =~ /^\d{1,2}$/ && pv1[16].empty?
      }
      @failed = pass?( messages, logic )
      @failed.should be_empty
    end
  
    types = [ :attending, :referring, :consulting, :admitting ]
    types.each{ |type|
      it "has a valid #{type} physician", :pattern => "ID, name, and (something)PROV" do
        logic = Proc.new{ |msg| is_physician? msg[:PV1].field(type) }
        @failed = pass?( @messages, logic )
        @failed.should be_empty
      end
    }  
  end
end

# shared by encounters and rad    
shared_examples "ADT and rad records" do  
  context "when converted to HL7" do   
    it "has the correct processing ID", :pattern => "T" do
      logic = Proc.new{ |msg| msg[:MSH].processing_id == "T" }
      @failed = pass?( @messages, logic )
      @failed.should be_empty      
    end
  end
    
  context "the encounter" do
    it "has a patient class" do
      logic = Proc.new{ |msg| msg[:PV1].patient_class !~ /[^A-z ]/ }
      @failed = pass?( @messages, logic )
      @failed.should be_empty
    end
  end
end

# shared by lab and rad
shared_examples "lab and rad records" do
  context "when converted to HL7" do   
    it "has the correct event type", :pattern => HL7::RESULT_MESSAGE_TYPE do
      logic = Proc.new{ |msg| msg[:MSH].event == HL7::RESULT_MESSAGE_TYPE }
      @failed = pass?( @messages, logic )
      @failed.should be_empty      
    end
  end
    
  context "the encounter" do
    it "has the same attending and referring physicians" do
      logic = Proc.new{ |msg|
        pv1 = msg[:PV1]
        pv1.referring.empty? || pv1.attending == pv1.referring
      }
      @failed = pass?( @messages, logic )
      @failed.should be_empty
    end   
  end
  
  context "the order request" do   # OBR segment 
    it "has a valid accession number", :pattern => "letters, numbers, and spaces" do
      logic = Proc.new{ |msg| msg[:OBR][3] !~ /[^A-Z0-9 ]/ }
      @failed = pass?( @messages, logic )
      @failed.should be_empty    
    end

    it "has a valid service ID", :pattern => "letters, numbers, and spaces" do
      logic = Proc.new{ |msg| msg[:OBR][4] !~ /[^A-Z0-9 \^]/ }
      @failed = pass?( @messages, logic )
      @failed.should be_empty    
    end 
  
    it "has a date/time" do
      logic = Proc.new{ |msg| HL7.is_datetime? msg[:OBR].observation_date_time }
      @failed = pass?( @messages, logic )
      @failed.should be_empty    
    end  

    it "has a valid ordering provider" do
      logic = Proc.new{ |msg| is_physician? msg[:OBR].field(:ordering_provider) }
      @failed = pass?( @messages, logic )
      @failed.should be_empty    
    end   

    it "has a result date/time", :pattern => "the same as the observation date/time" do
      logic = Proc.new{ |msg|
        obr = msg[:OBR]
        res = obr.field(:result_date_time)
        obs = obr.field(:observation_date_time)
        HL7.is_datetime?(res.to_s) && res.as_date == obs.as_date
      }
      @failed = pass?( @messages, logic )
      @failed.should be_empty    
    end 

    list = HL7::RESULT_STATUS
    it "has a valid result status", :pattern => "one of #{list.join(', ')}" do
      logic = Proc.new{ |msg| list.include? msg[:OBR].result_status }
      @failed = pass?( messages, logic )
      @failed.should be_empty
    end
  end      
end
