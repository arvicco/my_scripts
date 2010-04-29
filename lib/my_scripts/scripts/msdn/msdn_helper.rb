# Make sure Strings respond to snake_case (even if this helper is called out of containing lib context)
# This is needed when this file is required by RubyMine script "msdn_converter.rb"
unless "".respond_to? :snake_case
  class String
    def snake_case
      self.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
              gsub(/([a-z\d])([A-Z])/, '\1_\2').
              tr("-", "_").downcase
    end
  end
end

module MyScripts

  module MsdnHelper

    def self.convert(text, page_margin=6, page_width=110)
      # Removing extra lines and spaces
      text.gsub! /(^\s*|\r)/m, ""

      # Extracting original function/struct syntax (definition)
      syntax = text[/^Syntax.*?(}|\)).*?;/m]

      if syntax =~ /typedef struct/  # this is a struct description
        type = :struct

        name = syntax.match(/}\s*([\w*]*)/m)[1] # first word after }
        params = syntax.scan(/\s(\w*)\s           # member type is a first word, followed by whitespace
                                (\*?[\w]*)        # followed by member name
                                (?:\[([\w]*)\])?  # POSSIBLY followed by [array dimension] ( it may be number or CONST)
                                (?:\s*?;)/mx)     # ending with a semi-colon

        # Creating different representations of struct syntax
        ffi_params = params.map{|p| ":#{p[1].snake_case}, " + (p[2] ? "[:#{p[0]}, #{p[2]}]" : ":#{p[0]}")}.
                join(",\n         ")
        ffi_syntax = "\nclass #{name} < FFI::Struct\n  layout #{ffi_params}\nend\n"

        original_params = params.map{|p| "#{p[0]} #{p[1]}" + (p[2] ? "[#{p[2]}]" : "")}.join("; ")
        original_syntax = "[*Typedef*] struct { #{original_params} } #{name};"

      elsif syntax =~ /.\(.*\);/m  # this is a function descriptions
        type = :function

        returns, name = syntax.match(/(\w*\*?|\w*\*? \w*\*?) (\w*)\(/m)[1..2]
        params = syntax.scan(/\s(\w*\*?) (\w*)(?:,|\s*\);)/m)

        # Creating different representations of method(function) syntax
        ffi_params = params.map{|p| ":" + p.first}.join(", ")
        ffi_returns = returns =~ /BOOL/ ? ":int8, boolean: true" : ":#{returns}"
        ffi_syntax = "function :#{name}, [#{ffi_params}], #{ffi_returns}"

        original_params = params.empty? ? 'void' : params.map{|p| p.join(" ")}.join(", ")
        original_syntax = "[*Syntax*] #{returns} #{name}( #{original_params} );"

        call_syntax = "success = #{name.snake_case}(#{params.map{|p| p.last.snake_case}.join(", ")})"
        snake_syntax = "success = #{name.snake_case}(#{params.map{|p| "#{p.last.snake_case}=0"}.join(", ")})"
        camel_syntax = "success = #{name}(#{params.map{|p| "#{p.last.snake_case}=0"}.join(", ")})"

        # Adding Enhanced API description and :call-seq: directive
        text += "\n---\n<b>Enhanced (snake_case) API: </b>"
        text += "\n\n:call-seq:\n #{call_syntax}\n \n"

      else
        type = :unknown
        return 'Unknown syntax. Only functions and structs are converted.'
      end

      # Formatting params/members into two column table
      params.each {|p| text.gsub!(Regexp.new("^#{p[1]}\n"), "#{p[1]}:: ")}

      # Replacing MSDN idioms with RDoc ones, cutting some slack, adding extra info
      replace = {
              /^Syntax.*?(}|\)).*?;/m => "\n#{original_syntax}",
              /^Parameters\s*/m => "\n",
              /^Members\s*/m => "\n",
              /^Return Value\n\s*/m => "\n*Returns*:: ",
              /^Remarks\s*/m => "---\n*Remarks*:\n",
              }
      replace.each {|from, to| text.gsub!( from, to)}

      # Chopping long lines into smaller ones (while keeping indent)
      text_width = page_width - page_margin - 2
      lines = []
      text.split("\n").each do |line|
        list_label = line.match(/:: |^\[.*?\] /)
        indent = list_label ? list_label.end(0) : 0

        first_pattern = Regexp.new ".{1,#{text_width}}(?: |$)"
        chunk_pattern = Regexp.new ".{1,#{text_width - indent}}(?: |$)"
        if line.length < text_width || indent > text_width || !(first_chunk = line.match(first_pattern))
          lines << line
        else
          lines << first_chunk[0]
          line[first_chunk.end(0)..-1].scan(chunk_pattern).each do |chunk|
            lines << " " * indent + chunk
          end
        end
      end
      text = lines.join("\n")

      # Inserting initial white spaces with comment sign
      tab = " " * page_margin
      text.gsub! /^(?!##)/m, tab + "# "

      # Closing off with ffi syntax definition
      text += "\n#{tab}#{ffi_syntax}"

      if type == :function
        # Prepending function with RDoc meta-method hint
        text = "#{tab}##\n#{text}"

        # Extracting description
        description = text[Regexp.new "(?<=(?:^F|f)unction\\s).{1,#{text_width}}(?: |$)"]

        # Adding Rspec examples
        text += %Q[

    describe "##{name.snake_case}" do
      spec{ use{ #{camel_syntax} }}
      spec{ use{ #{snake_syntax} }}

      it "original api #{description}" do
        pending
        #{camel_syntax}
      end

      it "snake_case api #{description}" do
        pending
        #{snake_syntax}
      end

    end # describe #{name.snake_case}\n]
      end

      text
    end

  end
end

# if this script file is called directly, convert given file (default test.txt) to stdout
if __FILE__ == $0
  test_file = ARGV[0] || 'test.txt' # File.expand_path(File.dirname(__FILE__) + '/test')
  File.open(test_file) do |f|
    puts MyScripts::MsdnHelper.convert f.readlines.join("\n")
  end
end


