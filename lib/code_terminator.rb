require "code_terminator/version"
require "code_terminator/html"

module CodeTerminator
  # Your code goes here...
    def self.process(source="",code="")

      file = CodeTerminator::Html.new()
      file.new_file(source,code)
      file.print("hola")
      #code + " HI"
    end

end
