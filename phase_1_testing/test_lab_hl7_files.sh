for file in resources/lab_hl7/*
do
  FILE=$file rspec spec/hl7_specs/lab/lab_hl7_spec.rb
done
