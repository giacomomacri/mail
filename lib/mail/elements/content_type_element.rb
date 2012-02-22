# encoding: utf-8
module Mail
  class ContentTypeElement # :nodoc:
    
    include Mail::Utilities

    def initialize( string )
      parser = Mail::ContentTypeParser.new
      if tree = parser.parse(cleaned(string))
        @main_type = tree.main_type.text_value.downcase
        @sub_type = tree.sub_type.text_value.downcase
        @parameters = tree.parameters 
      else
        raise Mail::Field::ParseError.new(ContentTypeElement, string, parser.failure_reason)
      end
      
      if @main_type=="multipart" && @parameters.empty? && string.match(/boundary/i)
        parameters = string.match(/([\w\-]+\/[\w\-]+);\s+(.*)/i)
        param_string = []
        (1..parameters.length-1).each { |i| param_string << parameters[i] }
        tree = parser.parse(cleaned(param_string.join('; ')))
        @parameters = tree.parameters
      end
      
    end

    def main_type
      @main_type
    end

    def sub_type
      @sub_type
    end

    def parameters
      @parameters
    end

    def cleaned(string)
      string =~ /(.+);\s*$/ ? $1 : string
    end
    
  end
end
