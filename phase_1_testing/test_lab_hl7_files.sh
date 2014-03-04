for file in resources/lab_hl7/*
do
  FILE=$file rspec spec/lab/lab_spec.rb
done
