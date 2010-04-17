module MyScripts

  # This script converts text copied from MSND function or struct description
  # into RDoc-compatible comment format. It also adds function and spec stub
  # (both are used by Win gem). This reduces dramatically amount of manual work
  # needed to convert MSDN info into RDoc
  #
  class Msdn < Script
    VERSION = '0.0.1'

    def run
      usage "[in_file] File containing MSDN text (reads from stdin if no infile)" if @argv.size > 1

      p self.class.convert @argf.read
      puts self.class.convert @argf.read
    end

    def self.convert(text, page_margin=6, page_width=110)
      # Removing extra lines and spaces
      text.gsub! /^\s*|\r/m, ""

      # Analysing original function syntax (definition)
      syntax = text[/^Syntax.*?(}|\)).*?;/m]

      if syntax =~ /typedef struct/   # this is a struct description
        type = :struct
        name = syntax.match(/}\s*([\w*]*)/m)[1] # first word after }
        params = syntax.scan(/\s(\w*) (\*?[\w]*)(?:\[([\w]*)\])?(?:\s*?;)/m)
        ffi_syntax = "\nclass #{name} < FFI::Struct
    layout #{params.map{|p| ":#{p[1].snake_case}, " + (p[2] ? "[:#{p[0]}, #{p[2]}]" : ":#{p[0]}")}.join(",\n         ")}\nend\n"

        original_syntax = "[*Typedef*] struct { #{params.map{|p| "#{p[0]} #{p[1]}" + (p[2] ? "[#{p[2]}]" : "")}.join('; ')} } #{name};"
      else                            # this is a function description
        type = :function
        returns, name = syntax.match(/(\w*\*?|\w*\*? \w*\*?) (\w*)\(/m)[1..2]
        params = syntax.scan(/\s(\w*\*?) (\w*)(?:,|\s*\);)/m)

        # Creating different representations of method(function) syntax
        original_syntax = "[*Syntax*] #{returns} #{name}( #{params.empty? ? 'void' : params.map{|p| p.join(' ')}.join(', ')} );"
        call_syntax = "success = #{name.snake_case}(#{params.map{|p| p.last.snake_case}.join(', ')})"
        snake_syntax = "success = #{name.snake_case}(#{params.map{|p| "#{p.last.snake_case}=0"}.join(', ')})"
        camel_syntax = "success = #{name}(#{params.map{|p| "#{p.last.snake_case}=0"}.join(', ')})"
        ffi_syntax = "function :#{name}, [#{params.map{|p| ':' + p.first}.join(', ')}], #{
                returns =~ /BOOL/ ? ':int8, boolean: true' : ':' + returns}"

        # Adding Enhanced API description and :call-seq: directive
        text += "\n---\n<b>Enhanced (snake_case) API: </b>"
        text += "\n\n:call-seq:\n #{call_syntax}\n \n"
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

      end # describe #{name.snake_case}]
      end

      text
    end

  end
end