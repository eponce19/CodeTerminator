require 'Nokogiri'
require 'active_support/core_ext/string/filters'

class CodeTerminator::Html

  def initialize(args = {})
    @code = args[:code]
    @source = args[:source]
    @tags = Array.new
    @elements = Array.new
  end

    # Create a Html file with the code of the editor. Return a boolean that indicate if the file was created or not.
    #
    # Example:
    #   >> CodeTerminator::Html.new_file("hola_mundo.html", "<h1>Hola Mundo!</h1>")
    #   => true
    #
    # Arguments:
    #   source: (String)
    #   code: (String)

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


     # Get html elements of a html file. Return a list of Nokogiri XML objects.
     #
     # Example:
     #   >> CodeTerminator::Html.get_elements("hola_mundo.html")
     #   => [#<Nokogiri::XML::Element:0x3fe3391547d8 name="h1" children=[#<Nokogiri::XML::Text:0x3fe33915474c "Hola Mundo!">]>, #<Nokogiri::XML::Text:0x3fe33915474c "Hola Mundo!">]
     #
     # Arguments:
     #   source: (String)

   def get_elements(source)
     @elements = Array.new
     reader = Nokogiri::HTML(File.open(source))
     reader = remove_empty_text(reader)
     reader.at('body').attribute_nodes.each do |element_attribute|
       node[:parent] = "html"
       node[:tag] = "body"
       node[:attribute] = element_attribute.name if !element_attribute.name.nil?
       node[:value] = element_attribute.value if !element_attribute.value.nil?
       @elements << node
     end
     reader.at('body').children.each do |child|
      if child.attribute_nodes.empty?
        node = Hash.new
        node[:parent] = "body"
        node[:tag] = child.name
        node[:content] = child.text if child.text?
        @elements << node
      else
        child.attribute_nodes.each do |element_attribute|
          node = Hash.new
          node[:parent] = "body"
          node[:tag] = child.name
          node[:attribute] = element_attribute.name if !element_attribute.name.nil?
          node[:value] = element_attribute.value if !element_attribute.value.nil?
          @elements << node
        end
      end

      add_children(child) if child.children.any?
     end
     @elements
   end

     # Validate if the syntax is correct. Return an array with Nokogiri errors.
     #
     # Example:
     #   >> CodeTerminator::Html.validate_syntax("<h1>Hola Mundo!</h1")
     #   => [#<Nokogiri::XML::SyntaxError: expected '>'>]
     #
     # Arguments:
     #   code: (String)

   def validate_syntax(code)
     errors = Array.new

     begin
       Nokogiri::XML(code) { |config| config.strict }

       #validate if html follow w3, uncomment when check all the page
         #"<!DOCTYPE html>
         # <html>
         #   <head>
         #     <h1>asdasd</h1>
         #     <title>asdasd</title>
         #   </head>
         #   <body>
         #     <h1>hola</h1>
         #   </body>
         # </html>"
       # @validator = Html5Validator::Validator.new
       # @validator.validate_text(@html)

     rescue Nokogiri::XML::SyntaxError => e
       #errors[0] = "Check if you close your tags"
       errors[0] = e
     end

     errors
   end

     # Read a html file. Return the text of the file.
     #
     # Example:
     #   >> CodeTerminator::Html.read_file("hola_mundo.html")
     #   => "<h1>Hola Mundo!</h1>\n"
     #
     # Arguments:
     #   source: (String)

   def read_file(source)
     fileHtml = File.open(source, "r")
     text = ""
     begin
       fileHtml.each_line do |line|
         text << line
       end
       fileHtml.close
     rescue
       text = false
     ensure
       #fileHtml.close unless fileHtml.nil?
     end

     text
   end

     # Get the elements of the code in html format. Return a string with elements in html.
     #
     # Example:
     #   >> CodeTerminator::Html.print_elements([#<Nokogiri::XML::Element:0x3fe31dc42bfc name="h1" children=[#<Nokogiri::XML::Text:0x3fe31dc42b70 "hola mundo">]>, #<Nokogiri::XML::Text:0x3fe31dc42b70 "hola mundo">])
     #   => "name = h1<br><hr>name = text<br>content = hola mundo<br><hr>"
     #
     # Arguments:
     #   elements: (Array)

   def print_elements(elements)
     text = ""
     elements.each do |child|
       text << "parent = " + child[:parent] + "<br>" if !child[:parent].nil?
       text << "tag = " + child[:tag] + "<br>" if !child[:tag].nil?
       text << "attribute = " + child[:attribute] + "<br>" if !child[:attribute].nil?
       text << "value = " + child[:value] + "<br>" if !child[:value].nil?
       text << "content = " + child[:content] + "<br>" if !child[:content].nil?
       text << "<hr>"
     end
     text
   end

   # Get the instructions to recreate the html code. Return an array with strings .
   #
   # Example:
   #   >> CodeTerminator::Html.get_instructions(file.get_elements("exercises/test.html"))
   #   => ["Add the tag h2 in body", "Add the tag text in h2 with content 'hola test' ", "Add the tag p in body"]
   #
   # Arguments:
   #   instructions: (Array)

   def get_instructions(elements)
     text = ""
     instructions = Array.new
     elements.each do |child|
       if child[:tag]!="text"
         text << "Add the tag " + child[:tag]
         text << " in "  + child[:parent]  if !child[:parent].nil?
         text << " with an attribute '" + child[:attribute] + "' " if !child[:attribute].nil?
         text << " with value '" + child[:value] + "' " if !child[:value].nil?
       else
         text << " In " + child[:parent]+ " add the text '" + child[:content]  + "' "  if !child[:content].nil?
       end
       instructions.push(text)
       text = ""
     end
     instructions
   end



   # Match if the code have the same elements than the exercise. Return an array with the mismatches.
   #
   # Example:
   #
   #   hola_mundo.html
   # => <h1>Hola Mundo!</h1>
   #
   #   >> CodeTerminator::Html.match("hola_mundo.html","<h2>Hola Mundo!</h2>")
   #   => ["h1 not exist"]
   #
   # Arguments:
   #   source: (String)
   #   code: (String)

   def match(source, code)
     html_errors = Array.new

     code = Nokogiri::HTML(code)

     elements = get_elements(source)

     elements.each do |e|
       item = e[:tag]

       if item=="text"

         if !e[:content].nil?
           if code.css(e[:parent]).text != e[:content]
             node = Hash.new
             node[:element] = e
             node[:type] = 330
             node[:description] = e[:parent] + " haven't the same text " + e[:content]
             html_errors << node
           end
           #e[:content] == code.css()

        end

       else
       if code.css(e[:tag]).length > 0

         if !e[:attribute].nil?
           if code.css(e[:tag]).attribute(e[:attribute]).nil?
             node = Hash.new
             node[:element] = e
             node[:type] = 334
             node[:description] = e[:attribute] + " not exist in " + e[:tag]
             html_errors << node
           else
             if code.css(e[:tag]).attribute(e[:attribute]).value != e[:value]
               node = Hash.new
               node[:element] = e
               node[:type] = 333
               node[:description] = e[:attribute] + " not is the same value " +  e[:value]
               html_errors << node
             end
           end
         end

         if code.at_css(e[:tag]).parent.name != e[:parent]
           node = Hash.new
           node[:element] = e
           node[:type] = 440
           node[:description] =  e[:tag] + " not exist in " + e[:parent]
           html_errors << node
         end

       else

          if code.at_css(e[:tag]).nil?
            node = Hash.new
            node[:element] = e
            node[:type] = 404
            node[:description] =  e[:tag] + " not exist"
            html_errors << node
          end

       end

      end
     end


     html_errors
   end

   private

   def add_children(parent)
     parent.children.each do |child|
       if child.attribute_nodes.empty?
          node = Hash.new
          node[:parent] = parent.name
          node[:tag] = child.name
          node[:content] = child.text if child.text?
          @elements << node
       else
         child.attribute_nodes.each do |element_attribute|
           node = Hash.new
           node[:parent] = parent.name
           node[:tag] = child.name
           node[:attribute] = element_attribute.name if !element_attribute.name.nil?
           node[:value] = element_attribute.value if !element_attribute.value.nil?
           @elements << node
         end
       end
       add_children(child) if child.children.any?
     end
   end

   def remove_empty_text (reader)
     reader.at("body").children.each do |child|
       if child.text?
         child.remove if child.content.to_s.squish.empty?
       end
        check_children(child) if child.children.any?
     end
     reader
   end

   def check_children(parent)
     parent.children.each do |child|
       if child.text?
         child.remove if child.content.to_s.squish.empty?
       end
       check_children(child) if child.children.any?
     end
   end

  #end

end
