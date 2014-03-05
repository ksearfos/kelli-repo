require './Methods.rb'
require './MessageHandler.rb'
require './Message.rb'
require './Segment.rb'
require './Field.rb'

module HL7
  
  SEG_DELIM = "\n"            # split into segments across lines, currently
  FIELD_DELIM = "|"           # fields of a segment are separated by this
  COMP_DELIM = "^"            # components in a field are separated by this
  DUP_DELIM = "~"             # duplicate information in a single field is separated by this
  HDR = /\d+MSH|MSH/          # regex defining header row
  SSN = /^\d{9}$/             # regex defining social security number, which is just 9 digits, no dashes
  ID_FORMAT = /^[A-Z]?]d+$/   # regex defining a medical ID
  
  ORDER_MESSAGE_TYPE = "ORD^O01"
  RESULT_MESSAGE_TYPE = "ORD^R01"
  ENCOUNTER_MESSAGE_TYPE = "ADT^A08"
  
  UNITS = [ "","%","/hpf","/lpf","/mcL","IU/mL","K/mcL","M/mcL","PG","U","U/L","U/mL","fL","g/dL","h","lbs",
            "log IU/mL","mIU/mL","mL","mL/min/1.73 m2","mcIU/mL","mcg/dL","mcg/mL FEU","mg/24 h","mg/L","mg/dL",
            "mg/g crea","mlU/mL","mm Hg","mm/hr","mmol/L","ng/dL","ng/mL","nmol/L","pH units","pg/mL","seconds",
            "titer","weeks","years" ]

  ABNORMAL_FLAGS = [ "","I","CH","CL","H","L","A","U","N","C" ]
  
  RESULT_STATUS = %w[ D F N O S W P C X R U I ]
  
  SEXES = %w[ F M O U A N C ]
   
  MSH_FIELDS = { :sending_application => 2, :sending_facility => 3, :receiving_application => 4,
                 :receiving_facility => 5, :date_time => 6, :security => 7, :message_type => 8,
                 :message_control_id => 9, :processing_id => 10, :version => 11 } 

  # full list of PID fields can be found at http://www.corepointhealth.com/resource-center/hl7-resources/hl7-pid-segment              
  PID_FIELDS = { :set_id => 1, :patient_id => 3, :mrn => 3, :patient_name => 5, :mothers_maiden_name => 6,
                 :date_of_birth => 7, :dob => 7, :sex => 8, :race => 10, :address => 11, :country_code => 12,
                 :home_phone => 13, :business_phone => 14, :language => 15, :marital_status => 16,
                 :religion => 17, :account_number => 18, :ssn => 19, :drivers_license_number => 20,
                 :ethnic_group => 22, :birthplace => 23, :citizenship => 26, :military_status => 27,
                 :nationality => 28, :death_date_time => 29 }
                 
  # full list of PV1 fields can be found at http://jwenet.net/notebook/1777/1305.html                 
  PV1_FIELDS = { :set_id => 1, :patient_class => 2, :patient_location => 3, :admission_type => 4,
                 :attending_doctor => 7, :referring_doctor => 8, :consulting_doctor => 9,
                 :hospital_service => 10, :admit_source => 14, :admitting_doctor => 17, :patient_type => 18,
                 :visit_number => 19, :financial_class => 20, :diet_type => 38, :bed_status => 40,
                 :admit_date_time => 44, :discharge_date_time => 45, :current_balance => 46,
                 :total_charges => 47, :total_payments => 49, :visit_indicator => 51 }
                 
  # full list of OBR fields can be found at http://www.corepointhealth.com/resource-center/hl7-resources/hl7-obr-segment
  OBR_FIELDS = { :set_id => 1, :place_order_number => 2, :filler_order_number => 3, :control_code => 3,
                 :service_id => 4, :procedure_id => 4, :priority => 5, :observation_date_time => 7,
                 :speciment_received_date_time => 14, :specimen_source => 15, :ordering_provider => 16,
                 :order_callback_number => 17, :result_date_time => 22, :result_status => 25 }  
                 
  # full list of ORC fields can be found at http://www.mexi.be/documents/hl7/ch400009.htm
  ORC_FIELDS = { :order_control => 1, :place_order_number => 2, :filler_order_number => 3,
                 :order_status => 5, :response_flag => 6, :quantity => 7, :transaction_date_time => 9,
                 :entered_by => 10, :verified_by => 11, :ordering_provider => 12 }
                 
  # full list of OBX fields can be found at http://www.corepointhealth.com/resource-center/hl7-resources/hl7-obx-segment
  OBX_FIELDS = { :set_id => 1, :value_type => 2, :observation_id => 3, :component_id => 3, :sub_id => 4,
                 :value => 5, :units => 6, :reference_range => 7, :abnormal_flag => 8, :result_status => 11 }   

  # I cannot find a full list of NTE fields                 
  NTE_FIELDS = { :set_id => 1, :value => 3 }                                             

  
  def HL7::correct_id_format( val )
    val =~ /^[A-Z0-9]$/
  end
  
  def HL7::correct_name_format( val )
    val =~ /^[A-Za-z]$/
  end
  
  def HL7::is_extension?( val )
    return true if val.empty?
    val =~ /^[XVI]$/ ||       # roman numeral, e.g. III for The 3rd
    val =~ /^[A-Z]{2}[.]?/    # Jr., MD, etc.       
  end
  
  def HL7::is_year?( val )
    yr = val.to_s
    ( yr[0...2] == "19" || yr[0...2] == "20" ) && yr[2...4] =~ /\d{2}/
  end
  
  def HL7::is_month?( val )
    mo = val.to_i
    mo.between?( 1, 12 )
  end
  
  def HL7::is_day?( val )
    day = val.to_i
    day.between?( 1, 31 )
  end
  
  def HL7::is_hour?( val )
    hr = val.to_i
    hr.between?( 0, 23 )   # don't know if it's military time or not
  end
  
  # note this can be used for seconds too, since the format is the same
  def HL7::is_minute?( val )
    min = val.to_i
    min.between?( 0, 59 )
  end
  
  def HL7::correct_timestamp_format?( val )
    # MM-DD-YYYY HH:MM
    dt = val.split( " " )           # => [date,time]
    date = dt.first.split( "-" )    # => [MM,DD,YYYY]
    time = dt.last.split( ":" )     # => [HH,MM]

    is_month?( date[0] ) && is_day?( date[1] ) && is_year?( date[2] ) && is_hour?( time[0] ) && is_minute?( time[1] )
  end
  
  def HL7::is_a_name?( field )
    if correct_id_format( field.first )        # ID
      correct_name_format( field[1] ) &&
      correct_name_format( field[2] )
    elsif correct_name_format( field.first )    # last name
      correct_name_format( field[1] )
    else
      false
    end
  end
  
  def HL7::is_a_datetime?( val )
    yr = val[0...4]
    mo = val[4...6]
    day = val[6...8]
    hr = val[8...10]
    min = val[10...12]
    sec = val[12...14]
    
    ( yr && is_year?(yr) ) && ( mo && is_month?(mo) ) && ( day && is_day?(day) ) &&
    ( !hr || is_hour?(hr) ) && ( !min || is_min?(min) ) && ( !sec || is_minute?(sec) )
  end
  
  # returns true if string is numeric, i.e. an integer or a decimal
  # returns false if not
  def HL7::is_numeric?( str )
    str.strip!
    str.tr!( " ", "" )                    # remove spaces
    return false if str[0] !~ /-|\+|\d/   # first character is a digit or positive/negative sign?
    return false if str[-1] !~ /\d/       # last character is a digit?

    middle = str[1..-2] 
    return true if middle.empty?
    return middle =~ /^\d*\.?\d*$/        # middle is nothing but digits and a possible decimal point
  end
  
  def HL7::is_struct_numeric?( str )
    # first character, if not a digit, is -, <, >, <=, >=
    allowed_beg = [ "-", "<", ">", "<=", ">=" ]
    str.strip!
    str.tr!( " ", "" )
    num_i = str.index( /\d/ )
    beg = str[0...num_i]            # portion of string up to first digit
    rest = str[num_1..-1]           # portion of string beginning with first digit
    sep = rest.match( /\D+/ )[0]    # separator
    nums = rest.split( sep )        # numeric portions of string
    
    allowed_beg.include?( beg ) && ( sep ? nums.size == 2 : nums.size == 1 )
  end
  
  def HL7::is_num_range?( str )
    str.strip!
    str.tr!( " ", "" )    
    ary = str.split( "-" )
    return false if ary.size != 2   # if not, it isn't a range
              
    is_numeric?( ary[0] ) && is_numeric?( ary[1] )
  end
  
  def is_timestamp?( str )
    correct_timestamp_format?( str )
  end
  
  def is_text?( str )
    # value is text (matches 'TX' type) if there is a value, and that value doesn't match any other type
    !( str.empty? || is_struct_numeric?(str) || is_numeric?(str) || is_timestamp?(str) )
  end
end