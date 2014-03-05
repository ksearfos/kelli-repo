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
  
  # a list of all possible message types can be found at http://www.interfaceware.com/hl7-standard/hl7-messages.html
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

end