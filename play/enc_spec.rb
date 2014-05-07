When type == :enc
check_all "core"
check do
  event_type
  correct_segments(:PID, :MSH, :PV1, :EVN)
  correct_version
  patient_name
  patient_address
  patient_location
  admission_type
  admission_date
  discharge_date
  hospital_service
  admission_source
end