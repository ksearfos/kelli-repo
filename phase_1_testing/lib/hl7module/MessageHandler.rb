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
#         the text. It then breaks the text into individual records and initializes Message objects from those. It will also
#         keep track of each of those Messages and the value separators used by the message.
#       It is assumed that the file is in a valid text format and uses either the Windows-style line endings (\r and \r\n)
#         or the Unix style (\n). It also assumes the file is UTF-8 encoded.
#
# EXAMPLE: MessageHandler => "MSH|...MSH|...MSH|..." / [ Message1, Message2, Message 3 ]
#
# CLASS VARIABLES: none; uses HL7::SEG_DELIM and modifies HL7.separators
#
# READ-ONLY INSTANCE VARIABLES:
#    @message [String]: stores entire message text
#    @records [Array]: stores individual records as Message objects
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
# LAST UPDATED: 3/12/14 14:08
#
# LAST TESTED: 3/12/14
#
#------------------------------------------

module HL7Test
  
  class MessageHandler

    attr_reader :message, :records

    # NAME: new
    # DESC: creates a new HL7::MessageHandler object from a text file
    # ARGS: 1-2
    #  file [String] - complete path to the source file
    #  limit [Integer] - highest number of records to read in from the source file - by default there is no limit
    # RETURNS:
    #  [HL7::MessageHandler] newly-created MessageHandler
    # EXAMPLE:
    #  HL7::MessageHandler.new( "C:\records.txt", 2 ) => new MessageHandler pointed to records.txt, with 2 records total  
    def initialize( file )
      @message = ""
      @records = []
      
      read_message( file )    # updates @message
      get_separators          # updates HL7Test::@separators
      break_into_records      # updates @records
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
    
    def view_separators
      HL7Test.separators.each{ |type,val| puts type.to_s + ": " + val }
    end

    def separators
      HL7Test.separators.values
    end
    
    private

    @@eol = "\n"             # the end of line character we are using
        
    # reads in a HL7 message as a text file from the given filepath and stores it in @message
    # changes coding to end in \n for easier parsing
    def read_message( file )
      chars = ""
     
      puts "Reading #{file}..."
      File.open( file, "r" ).each_char{ |ch| 
        if ch == "\r" then chars << @@eol
        else chars << ch
        end
      }

      chars.gsub!( '\\r', @@eol )
      chars.squeeze!( @@eol )                # only need one line break at a time
      
      chars.gsub!( "'MSH", "#{@@eol}MSH" )
      ary = chars.split( @@eol )
      ary.delete_if{ |line| line !~ /^\d*[A-Z]{3}\|/ }  # non-segment lines
      
      @message = ary.join( SEG_DELIM )      # now glue the pieces back together, ready to be read as HL7 segments
    end                                     # though @@eol and SEG_DELIM are likely the same, they don't have to be!

    def get_separators
      eol = @message.index( SEG_DELIM )
      line = @message[0...eol]         # looks something like: MSH|^~\&|info|info|info
      
      i = line.index( "MSH" )          # index marking the beginning of the first occurrence of 'MSH'
      i += 3                           # i was index of the M in MSH; need index of first character after H
      HL7Test.separators[:field] = line[i]
      HL7Test.separators[:comp] = line[i+1]
      HL7Test.separators[:subcomp] = line[i+2]
      HL7Test.separators[:subsub] = line[i+3]
      HL7Test.separators[:sub_subsub] = line[i+4]  
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
      hdrs = @message.scan( HDR )           # all headers (will be needed later)
      recs = @message.split( HDR )[1..-1]   # split across headers, yielding individual records
      
      all_recs = []
      for i in 0...hdrs.size
        all_recs << ( hdrs[i] + recs[i] )
      end
      
      all_recs
    end

  end

end