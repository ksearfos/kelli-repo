for /f %%f in ('dir /s/b resources\lab_hl7\*') do (
set FILE=%%f 
rspec spec\lab\lab_spec.rb
)