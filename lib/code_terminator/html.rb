#class CodeTerminator::Html
  #class CodeTerminator::Html

class CodeTerminator::Html

  def initialize(args = {})
    @code = args[:code]
    @source = args[:source]
  end

   def new_file(source,code)
     fileHtml = File.new(source, "w+")
     result = true
     begin
       fileHtml.puts code
     rescue
       result = false
     ensure
       fileHtml.close unless fileHtml.nil?
     end
     #return true if file was succesfully created
     result
   end

   def print(text)
     p text
   end

  #end

end
