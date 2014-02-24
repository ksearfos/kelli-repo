DIR = "C:\\Users\\Owner\\Dropbox\\2013_OhioHealth\\HL7\\ExampleHL7"
FILE1 = "manifest_lab_in"
FILE2 = "manifest_lab_out"
OUT1 = "file1.txt"
OUT2 = "file2.txt"
EOL_CH = "\r"       # stupid microsoft

puts "Reading file 1..."
f1 = ""
File.open( DIR + "\\" + FILE1 ) { |f|
    f1 = f.gets.chop
  }
  
puts "Reading file 2..."
f2 = ""
File.open( DIR + "\\" + FILE2 ) { |f|
    f2 = f.gets.chop
  }

f1_ary = f1.split( EOL_CH )     # only want to split across lines, and default splits across all whitespace
f2_ary = f2.split( EOL_CH )

f1_ary.sort!
f2_ary.sort!

s1 = f1_ary.size
s2 = f2_ary.size

last = ( s1 >= s2 ? s1 : s2 )

for i in (0...last)
  f1_ary
end
