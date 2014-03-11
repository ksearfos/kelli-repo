#------------------------------------------
#
# MODULE: HL7
#
# CLASS: HL7::MessageHandler
#
# DESC: Defines an object to read HL7 message from a file and split it into Message objects. Basically sets the stage
#         for treating the file text as a HL7 message.
#       Performs minor reformatting to insure there are no blank lines, and all line breaks are done with \n and not \r
#       The message handler class takes a filepath where HL7 data is stored, reads from it, and standardizes the format of
#         the text. It then breaks the text into individual records and initiales Message objects from those. It will also
#         keep track of each of those Messages and the value separators used by the message. Lastly, it will create new
#         Segment child classes for each type of segment that appears in the message (which are used when initializing
#         Messages).
#       It is assumed that the file is in a valid text format and uses either the Windows-style line endings (\r and \r\n)
#         or the Unix style (\n). It also assumes the file is UTF-8 encoded.
#
# EXAMPLE: MessageHandler => "MSH|...MSH|...MSH|..." / [ Message1, Message2, Message 3 ]
#
# CLASS VARIABLES: uses HL7::SEG_DELIM and modifies HL7.separators
#    @@lim_default [Integer]: default limit to the number of records to read in, False (no limit) as written
#                      ====>  if @@lim_default evaluates to False and no other limit is specified, will read in all records
#                      ====>  can ignore @@lim_default by passing a second argument to new()
#    @@eol [String]: defines the end-of-line character we want to use, "\n" as written
#
# READ-ONLY INSTANCE VARIABLES:
#    @message [String]: stores entire message text
#    @records [Array]: stores individual records as Message objects
#    @segment_types [Array]: stores list of the types of segments found in the message
#
# CLASS METHODS: none
#
# INSTANCE METHODS:
#    new(file,limit): creates new MessageHandler object and reads in text from file, up to limit records (if specified)
#    to_s: returns String form of MessageHandler, which is the text of the file
#    [](index): returns Message at given index
#    each(&block): loops through each record, executing given code
#    method_missing: tries to call method on @records (Array)
#                    then tries to call method on @message (String)
#                    then gives up and throws exception
#
# CREATED BY: Kelli Searfos
#
# LAST UPDATED: 3/10/14 11:09 AM
#
# LAST TESTED: 3/4/14
#
#------------------------------------------

module HL7Test
  
  class MessageHandler
    @@lim_default = false    # limit will be an integer, but this is ruby so let's take advantage of dynamic typing!
    @@eol = "\n"             # the end of line character we are using
    
    attr_reader :message, :records, :segment_types

    # NAME: new
    # DESC: creates a new HL7::MessageHandler object from a text file
    # ARGS: 1-2
    #  file [String] - complete path to the source file
    #  limit [Integer] - highest number of records to read in from the source file - by default there is no limit
    # RETURNS:
    #  [HL7::MessageHandler] newly-created MessageHandler
    # EXAMPLE:
    #  HL7::MessageHandler.new( "C:\records.txt", 2 ) => new MessageHandler pointed to records.txt, with 2 records total  
    def initialize( file, limit = @@lim_default )
      @message = ""
      @records = []
      @segment_types = [:MSH]
      
      read_message( file, limit )    # updates @message
      prepare                        # updates @segment_types, @separators -- prepare to create Message/Segment objects
      break_into_records             # updates @records
    end

    # NAME: to_s
    # DESC: returns the message handler as a String object - basically the text of the file
    # ARGS: none 
    # RETURNS:
    #  [String] the message handler source in textual form
    # EXAMPLE:
    #  message_handler.to_s => "MSH|...MSH|...MSH|..."     
    def to_s
      @message
    end

    # NAME: []
    # DESC: returns record (Message object) at given index
    # ARGS: 1
    #  index [Integer] - the index of the record we want
    # RETURNS:
    #  [Message] an individual Message/record
    # EXAMPLE:
    #  message_handler[2] => Message3    
    def []( index )
      @records[index]
    end

    # NAME: each
    # DESC: performs actions for each record
    # ARGS: 1
    #  [code block] - the code to execute on each component
    # RETURNS: nothing, unless specified in the code block
    # EXAMPLE:
    #  message_handler.each{ |rec| print rec.id + " & " } => 12345 & 12458 & 12045 
    def each
      @records.each{ |rec| yield(rec) }
    end

    # NAME: method_missing
    # DESC: handles methods not defined for the class
    # ARGS: 1+
    #  sym [Symbol] - symbol representing the name of the method called
    #  *args - all arguments passed to the method call
    #  [code block] - optional code block passed to the method call
    # RETURNS: depends on handling
    #     ==>  first checks @records for a matching method
    #     ==>  second checks @message for a matching method
    #     ==>  then gives up and throws an Exception
    # EXAMPLE:
    #  message_handler.size => 3 (calls @records.size)
    #  message_handler.gsub( "*", "|" ) => "MSH*...MSH*...MSH*..."  (calls @message.gsub)
    #  message_handler.fake_method => throws NoMethodError    
    def method_missing( sym, *args, &block )
      if Array.method_defined?( sym )
        @records.send( sym, *args )
      elsif String.method_defined?( sym )
        @message.send( sym, *args )
      else
        super
      end
    end
    
    private
    
    # reads in a HL7 message as a text file from the given filepath and stores it in @message
    # changes coding to end in \n for easier parsing
    def read_message( file, limit = @@lim_default )
      valid_limit = ( limit && limit > 0 )     # is there a real limit specified?
      chars = ""                               #+  user could say limit = -1 but that isn't helpful
      do_break = false
      
      puts "Reading #{file}..."
      File.open( file, "r" ).each_char do |ch|
        if ch == "\r" then chars << @@eol   # convert to useful character
        else chars << ch
        end

        do_break = valid_limit && chars.scan(HDR).size > limit    # if we have a limit, and we have reached it,
        break if do_break                                           #+ stop reading file
      end
      
      chars.squeeze!( @@eol )               # only need one line break at a time
      ary = chars.split( @@eol )
      ary.pop if do_break                   # remove last line ONLY IF it's the header of an unwanted record
      ary.delete_if{ |line| line !~ /\S/}   # remove any lines that are empty
      
      @message = ary.join( SEG_DELIM )      # now glue the pieces back together, ready to be read as HL7 segments
    end                                     # though @@eol and SEG_DELIM are likely the same, they don't have to be!

    def prepare
      get_separators
      define_segments
    end
    
    def define_segments
      fld = HL7.separators[:field]
      ary = @message.split( SEG_DELIM )
      ary.each{ |line|
        type = line.split( fld ).first     # first field of each line, i.e. the segment type
        @segment_types << type.upcase.to_sym unless type =~ HDR
      }
      
      @segment_types.uniq!                 # a list of all segment types included in this message 
      @segment_types.each{ |type|
        HL7Test.new_typed_segment( type )
      }
    end
    
    def get_separators
      eol = @message.index( SEG_DELIM )
      line = @message[0...eol]         # looks something like: MSH|^~\&|info|info|info
      
      i = line.index( "MSH" )          # index marking the beginning of the first occurrence of 'MSH'
      i += 3                           # i was index of the M in MSH; need index of first character after H
      HL7.separators[:field] = line[i]
      HL7.separators[:comp] = line[i+1]
      HL7.separators[:subcomp] = line[i+2]
      HL7.separators[:subsub] = line[i+3]
      HL7.separators[:sub_subsub] = line[i+4]  
    end
        
    # sets @records to contain all HL7 messages contained within @message, as HL7::Message objects
    # can access segments as @records[index][segment_name]
    # e.g. hl7_messages_array[2][:PID] will return the PID segment of the 3rd record
    def break_into_records
      all_recs = records_by_text
      @records = all_recs.map{ |msg| Message.new( msg ) }
    end
        
    # returns array of strings containing hl7 message of individual records, based on @message
    def records_by_text
      hdrs = @message.scan( HDR )      # all headers (will be needed later)
      recs = @message.split( HDR )     # split across headers, yielding individual records
      
      all_recs = []
      for i in 0...hdrs.size
        all_recs << hdrs[i] + recs[i].chomp      # those pesky endline characters cause a LOT of problems!
      end

      all_recs
    end

  end

end