dir = File.dirname( __FILE__ )
require "#{dir}/OHMethods.rb"

module OHProcs

  extend HL7Test
  
  private
    
  IMP_PROC = Proc.new{ |val| val.include?( "IMPRESSION:" ) }
  ADT_PROC = Proc.new{ |val| val.include?( "ADDENDUM:" ) }
  PT_CLASSES = %w( Emergency Outpatient Inpatient Observation Q O E )
  PT_LOCS = %w( ED ISD EDO 7N 5W CSD 5OC 4DE EPY AEC 5DE )
  OBS_TYPES = %w( TX NM SN )
  RAD_OBS_IDS = %w( &GDT &IMP &ADT )
  
  # -------------Define the Procs------------ #
  # MSH
  MSH9_NOT_ORD = Proc.new{ |rec| rec.header[9] != 'ORU^R01' }
  MSH9_NOT_ADT = Proc.new{ |rec| rec.header[9] != 'ADT^A08' }
  MSH10_P = Proc.new{ |rec| is_val?(rec,"msh10",'P') }
  MSH10_T = Proc.new{ |rec| is_val?(rec,"msh10",'T') }
  MSH11_23 = Proc.new{ |rec| is_val?(rec,"msh11",'2.3') }
  MSH11_24 = Proc.new{ |rec| is_val?(rec,"msh11",'2.4') }
  
  # PV1
  define_group( "pv12", PT_CLASSES, :patient_class )    # PV12_VALS
  PV12_NOT_NULL = Proc.new{ |rec| rec[:PV1][2].to_s != "Null value detected" }
  define_group( "pv13", PT_LOCS, :patient_location )    # PV13_VALS
  PV17 = Proc.new{ |rec| has_val?(rec,"pv17") }
  PV18 = Proc.new{ |rec| has_val?(rec,"pv18") }
  PV19 = Proc.new{ |rec| has_val?(rec,"pv19") }
  PV117 = Proc.new{ |rec| has_val?(rec,"pv117") }
  PV17_AND_PV18 = Proc.new{ |rec| PV17.call(rec) && PV18.call(rec) }
  PV118 = Proc.new{ |rec| has_val?(rec,"pv118") }
  PV120 = Proc.new{ |rec| has_val?(rec,"pv120") }
  PV136 = Proc.new{ |rec| has_val?(rec,"pv136") }
  PV144 = Proc.new{ |rec| has_val?(rec,"pv144") }
  PV145 = Proc.new{ |rec| has_val?(rec,"pv145") }
  
  # OBX
  define_group( "obx2", OBS_TYPES, :observation_type )    # OBX2_VALS
  OBX3 = Proc.new{ |rec| has_val?(rec,"obx3") }
  OBX3_3_NOT_LA01 = Proc.new{ |rec| 
    obx3s = rec.fetch_field("obx3")
    obx3s.each{ |f| return true if f[3] != "LA01" }
    return false  #otherwise
  }
  define_group( "obx3", RAD_OBS_IDS, :observation_id )    # OBX3_VALS
  OBX5_IMP = Proc.new{ |rec| matches?(rec,"obx5",IMP_PROC) }
  OBX5_ADT = Proc.new{ |rec| matches?(rec,"obx5",ADT_PROC) }
  OBX5_SN = Proc.new{ |rec| is_type?( rec,"obx5",:SN ) }
  OBX5_NM = Proc.new{ |rec| is_type?( rec,"obx5",:NM ) }
  OBX5_TX = Proc.new{ |rec| is_type?( rec,"obx5",:TX ) }
  define_group( "obx11", HL7Test::ABNORMAL_FLAGS, :abnormal_flag )    # OBX11_VALS
  
  # PID
  PID3 = Proc.new{ |rec| has_val?(rec,"pid3") } 
  PID5 = Proc.new{ |rec| has_val?(rec,"pid5") }
  PID7 = Proc.new{ |rec| has_val?(rec,"pid7") }
  define_group( "pid8", HL7Test::SEXES, :sex )    # PID8_VALS
  PID10 = Proc.new{ |rec| has_val?(rec,"pid10") }
  PID11 = Proc.new{ |rec| has_val?(rec,"pid11") }  
  PID11_7 = Proc.new{ |rec| comp_has_val?(rec,"pid11",7) }  
  PID12 = Proc.new{ |rec| has_val?(rec,"pid12") } 
  PID12_AND_11_7 = Proc.new{ |rec| PID11_7.call(rec) && PID12.call(rec) }
  PID15 = Proc.new{ |rec| has_val?(rec,"pid15") }
  PID16 = Proc.new{ |rec| has_val?(rec,"pid16") }  
  PID17 = Proc.new{ |rec| has_val?(rec,"pid17") } 
  PID18_AND_PV119 = Proc.new{ |rec| has_val?(rec,"pid18") && has_val?(rec,"pv119") }  
  PID19 = Proc.new{ |rec| has_val?(rec,"pid19") }
   
  # ORC
  ORC = Proc.new{ |rec| rec[:ORC] }  # if there is no ORC, then rec[:ORC] == nil, which is always false
  ORC1 = Proc.new{ |rec| has_val?(rec,"orc1") }
  
  # OBR
  OBR7 = Proc.new{ |rec| has_val?(rec,"obr7") } 
  OBR7_AND_OBR22 = Proc.new{ |rec| 
    obr7 = rec[:OBR][7].as_date          # it's important to convert to dates because rad
    obr22 = rec[:OBR][22].as_date        #+ includes time, but we don't need times to be the same
    obr7 != obr22
  }
  OBR22 = Proc.new{ |rec| has_val?(rec,"obr22") }
  define_group( "obr25", HL7Test::RESULT_STATUS, :result_status )    # OBR25_VALS  
  OBR27 = Proc.new{ |rec| has_val?(rec,"obr27") } 
  OBR31 = Proc.new{ |rec| has_val?(rec,"obr31") }
  
  # OTHER
  EVN = Proc.new{ |rec| rec[:EVN] }
  
  #-------------Group Procs for Quick Access-------------- #

  # LAB
  LAB = { :observation_value_is_structured_numeric => OBX5_SN, :observation_value_is_numeric => OBX5_NM,
          :observation_value_is_text => OBX5_TX, :attending_and_referring_doctors_listed => PV17_AND_PV18,
          :order_control_id_listed => ORC1 }
  ALL_LAB = LAB + OBX2_VALS + OBX11_VALS
            
  RAD = { :matching_ORC_segment => Proc.new{ |rec| rec.segment_before(:OBX) == :ORC }, :exam_end_date_listed => OBR27,
          :reason_for_study_listed => OBR31, :observation_value_is_impression => OBX5_IMP, :observation_value_is_addendum => OBX5_ADT  }
  ALL_RAD = RAD + OBX3_VALS + PV12_VALS + PV13_VALS
  
  ADT = { :message_event_not_encounter => MSH9_NOT_ADT, :EVN_segment_present => EVN, :patient_language_listed => PID15,
          :valid_patient_class => PV12_NOT_NULL, :patient_race_listed => PID10, :patient_religion_listed => PID17,
          :patient_marital_status_listed => PID16, :country_codes_match => PID12_AND_11_7, :admission_date_listed => PV144,
          :discharge_date_listed => PV145, :patient_type_listed => PV118, :financial_class_listed => PV120,
          :discharge_disposition_listed => PV136 }
  
  ORDERS = { :message_event_not_order => MSH9_NOT_ORD, :result_date_is_not_collection_date => OBR7_AND_OBR22 } 
  ALL_ORDERS = ORDERS + OBR25_VALS
  
  CORE = { :processing_id_of_T => MSH10_T, :message_version_2_3 => MSH11_23, :processing_id_of_P => MSH10_P,
           :message_version_2_4 => MSH11_24, :attending_doctor_listed => PV17, :referring_doctor_listed => PV18,
           :consulting_doctor_listed => PV19, :admitting_doctor_listed => PV117, :visit_id_listed_twice => PID18_AND_PV119 }                 
  ALL_CORE = CORE + PID8_VALS
  
  public
  
  @lab = ALL_CORE + ALL_ORDERS + ALL_LAB
  @rad = ALL_CORE + ALL_ORDERS + ALL_RAD
  @adt = ALL_CORE + ADT
  class << self
    attr_reader :lab, :rad, :adt
  end
  
end