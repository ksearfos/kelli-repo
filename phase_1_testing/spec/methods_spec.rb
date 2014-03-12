# last run: 3/12/14 8:47 AM
# outcome: success

require "spec_helper.rb"

describe "HL7 module" do
  describe "method" do
    
    describe "make_date" do    
      it "makes date look like MM/DD/YYYY" do
        HL7Test.make_date($date_str).should == $date_str_as_date       
      end
      
      it "makes date look like MM - DD - YYYY" do
        delim = " - "
        HL7Test.make_date($date_str).should == $date_str_as_date.gsub(delim,"/")
      end
    end

    describe "make_time" do     
      it "shows time on a 12-hr clock" do
        HL7Test.make_time($time_str).should == $time_str_as_12hr
      end
      
      it "shows time in military time" do
        HL7Test.make_time($time_str,true).should == $time_str_as_24hr
      end      
    end 

    describe "make_datetime" do     
      it "displays date and time properly" do
        HL7Test.make_datetime($date_time_str).should == $date_str_as_date + " " + $time_str_as_12hr
      end      
    end 
    
    describe "make_name" do
      it "shows a very simple name" do
        HL7Test.make_name($sm_name_str).should == $sm_name_str_as_name
      end
      
      it "shows a name with a lot of pieces" do
        HL7Test.make_name($name_str).should == $name_str_as_name
      end
    end

    describe "is_suffix?" do      
      context "a roman numeral" do
        it "is a suffix" do
          HL7Test.is_suffix?('VIII').should be_true
        end
      end #roman numeral
      
      context "Jr or Sr" do
        it "is a suffix" do
          HL7Test.is_suffix?('Sr.').should be_true
          HL7Test.is_suffix?('JR').should be_true
        end
      end #Jr/Sr
      
      context "a nickname" do
        it "is not a suffix" do
          HL7Test.is_suffix?('"Killer"').should_not be_true
        end
      end #nickname
    end

    describe "is_year?" do
      context "a year in the last century" do
        it "is a year" do
          HL7Test.is_year?("1928").should be_true
          HL7Test.is_year?("2003").should be_true
        end
      end #last century
      
      context "a year from before the 1900s" do
        it "is not a year" do
          HL7Test.is_year?("1684").should_not be_true
        end
      end #old year
      
      context "a random collection of numbers" do  
        it "is not a year" do
          HL7Test.is_year?("53").should_not be_true
        end
      end #random numbers
      
      context "has no digits at all" do  
        it "is not a year" do
          HL7Test.is_year?("nineteen fifty-four").should_not be_true
        end
      end #no digits 
    end

    describe "is_month?" do
      context "number between 1 and 12" do
        it "is a month" do
          HL7Test.is_month?("11").should be_true
          HL7Test.is_month?("1").should be_true
        end
      end #numeric
      
      context "non-numeric month" do
        it "is not a month" do
          HL7Test.is_month?("September").should_not be_true
        end
      end #non-numeric
      
      context "number greater than 12" do
        it "is not a month" do
          HL7Test.is_month?("100").should_not be_true
        end
      end #wrong range
    end
    
    describe "is_day?" do
      context "number between 1 and 31" do
        it "is a day" do
          HL7Test.is_day?("24").should be_true
          HL7Test.is_day?("6").should be_true
        end
      end #numeric
      
      context "non-numeric" do
        it "is not a day" do
          HL7Test.is_day?("Halloween").should_not be_true
        end
      end #non-numeric
      
      context "number greater than 31" do
        it "is not a day" do
          HL7Test.is_month?("56").should_not be_true
        end
      end #wrong range
    end   
    
    describe "is_hour?" do
      context "2-digit number between 0 and 23" do
        it "is an hour" do
          HL7Test.is_hour?("20").should be_true
          HL7Test.is_hour?("07").should be_true
        end
      end #numeric
      
      context "non-numeric" do
        it "is not an hour" do
          HL7Test.is_hour?("noon").should_not be_true
        end
      end #non-numeric
      
      context "number greater than 23" do
        it "is not an hour" do
          HL7Test.is_hour?("30").should_not be_true
        end
      end #wrong range
    end      
    
    describe "is_min_sec?" do
      context "2-digit number between 0 and 60" do
        it "is a minute or second" do
          HL7Test.is_min_sec?("48").should be_true
          HL7Test.is_min_sec?("00").should be_true
        end
      end #numeric
      
      context "non-numeric" do
        it "is not a day" do
          HL7Test.is_min_sec?("Halloween").should_not be_true
        end
      end #non-numeric
      
      context "number greater than 59" do
        it "is not a day" do
          HL7Test.is_month?("60").should_not be_true
        end
      end #wrong range
    end  
        
    describe "is_date?" do
      context "a recent date, #{$date_str}" do
        it "is a date" do
          HL7Test.is_date?($date_str).should be_true
        end
      end #recent date
      
      context "an older date, 18120426" do
        it "is not a date" do
          HL7Test.is_date?("18120426").should_not be_true
        end
      end #old date
      
      context "gibberish" do
        it "is not a date" do
          HL7Test.is_date?("St. Swimmin's Day").should_not be_true
        end
      end #gibberish
    end

    describe "is_time?" do
      context "valid hours, minutes, and if present, seconds" do
        it "is a time" do
          HL7Test.is_time?($time_str).should be_true
          HL7Test.is_time?("0024").should be_true
        end
      end #proper time
      
      context "invalid hours, minutes, or seconds" do
        it "is not a time" do
          HL7Test.is_time?("3614").should_not be_true
          HL7Test.is_time?("1485").should_not be_true
          HL7Test.is_time?("143685").should_not be_true
        end
      end #improper time
      
      context "gibberish" do
        it "is not a time" do
          HL7Test.is_time?("8AM").should_not be_true
        end
      end #gibberish
    end

    describe "is_datetime?" do
      context "valid date followed by valid time" do
        it "is a date/time" do
          HL7Test.is_datetime?($date_time_str).should be_true
        end
      end #proper time
      
      context "invalid date or time" do
        it "is not a date/time" do
          HL7Test.is_datetime?("184619230537").should_not be_true
          HL7Test.is_datetime?("194609234537").should_not be_true
        end
      end #improper time
      
      context "gibberish" do
        it "is not a time" do
          HL7Test.is_time?("1111111").should_not be_true
        end
      end #gibberish
    end
    
    describe "is_numeric?" do
      context "an integer" do
        it "is numeric" do
          HL7Test.is_numeric?("26").should be_true
          HL7Test.is_numeric?("-674").should be_true
        end
      end #integer
      
      context "a decimal" do
        it "is numeric" do
          HL7Test.is_numeric?("2.6").should be_true
          HL7Test.is_numeric?("-608.74").should be_true
          HL7Test.is_numeric?("+8.000000").should be_true
        end
      end #decimal
      
      context "a range or proportion" do
        it "is not numeric" do
          HL7Test.is_numeric?("1-10").should_not be_true
          HL7Test.is_numeric?("23/98").should_not be_true
        end
      end #range
    end
 
    describe "is_struct_num?" do
      context "an integer" do
        it "is not a structured numeric" do
          HL7Test.is_struct_num?("26").should_not be_true
          HL7Test.is_struct_num?("-674").should_not be_true
        end
      end #integer
      
      context "a decimal" do
        it "is not a structured numeric" do
          HL7Test.is_struct_num?("2.6").should_not be_true
          HL7Test.is_struct_num?("-608.74").should_not be_true
          HL7Test.is_struct_num?("+8.000000").should_not be_true
        end
      end #decimal
      
      context "a ratio" do
        it "is a structure numeric" do
          HL7Test.is_struct_num?("1/10").should be_true
          HL7Test.is_struct_num?("23:98").should be_true
          HL7Test.is_struct_num?("2.3 / 98").should be_true
          HL7Test.is_struct_num?("-3/8").should be_true
        end
      end #range
      
      context "an inequality" do
        it "is a structure numeric" do
          HL7Test.is_struct_num?(">-110").should be_true
          HL7Test.is_struct_num?("<=23/98").should be_true
          HL7Test.is_struct_num?("<> 5.68").should be_true
        end
      end #comparative
      
      context "an interval" do
        it "is a structured numeric" do
          HL7Test.is_struct_num?("1 - 10").should be_true
          HL7Test.is_struct_num?("-1.5 - 10.0").should be_true
        end
      end #interval
      
      context "a categorical" do
        it "is a structure numeric" do
          HL7Test.is_struct_num?("3+").should be_true
          HL7Test.is_struct_num?("-2.5+").should be_true
        end
      end #categorical
    end
    
    describe "is_text?" do
      context "a numeric" do
        it "is not text" do
          HL7Test.is_text?("26").should_not be_true
          HL7Test.is_text?("-67.4").should_not be_true
        end
      end #numeric
      
      context "a structure_numeric" do
        it "is not text" do
          HL7Test.is_text?("< 2.6").should_not be_true
          HL7Test.is_text?("5 - 9").should_not be_true
          HL7Test.is_text?("5+").should_not be_true
        end
      end #structured numeric
      
      context "gibberish" do
        it "is text" do
          HL7Test.is_text?("I like pizza").should be_true
          HL7Test.is_text?(" 209%slkjshfgk  !@# ").should be_true
        end
      end #gibberish
    end    

    describe "has_correct_format?" do
      context "TX" do
        it "has the correct format if the value is text" do
          HL7Test.has_correct_format?("pizza","TX").should be_true
        end
        
        it "has the incorrect format if the value is not text" do
          HL7Test.has_correct_format?("<85","TX").should_not be_true
        end
      end #TX
      
      context "NM" do
        it "has the correct format if the value is numeric" do
          HL7Test.has_correct_format?("-4","NM").should be_true
        end
        
        it "has the incorrect format if the value is not numeric" do
          HL7Test.has_correct_format?("eighty-five","NM").should_not be_true
        end
      end #NM
      
      context "SN" do
        it "has the correct format if the value is a structured numeric" do
          HL7Test.has_correct_format?("<=1.56","SN").should be_true
        end
        
        it "has the incorrect format if the value is not a structured numeric" do
          HL7Test.has_correct_format?("85","SN").should_not be_true
        end
      end #SN
      
      context "any other format" do
        it "never has the correct format" do
          HL7Test.has_correct_format?("B","letter").should_not be_true
        end
      end #letter
    end     

  end
end
