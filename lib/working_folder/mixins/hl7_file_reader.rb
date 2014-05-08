module HL7FileReader
  def specify_hl7_file_requirements(directory, type)
    @hl7_directory = directory
    @message_type = type
  end
  
  def read_in_files
    @hl7_files = Dir.entries(@hl7_directory).select { |file| is_correct_type?(file) } 
    @hl7_files.map! { |filename| File.join(@hl7_directory, filename) }
  end
  
  def is_correct_type?(filename)
    fullname = "#{@hl7_directory}/#{filename}"
    File.file?(fullname) && filename =~ /^#{@message_type}_\w+/
  end
end