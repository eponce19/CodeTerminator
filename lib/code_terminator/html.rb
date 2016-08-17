require 'Nokogiri'
require 'active_support/core_ext/string/filters'

class CodeTerminator::Html

  def initialize(args = {})
    @code = args[:code]
    @source = args[:source]
    @tags = Array.new
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
     reader = Nokogiri::HTML(File.open(source))
     reader = remove_empty_text(reader)
     reader.at('body').children.each do |child|
       @tags.push(child)
       add_children(child) if child.children.any?
     end
     @tags
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
       xml = Nokogiri::XML(code) { |config| config.strict }

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
       text = "error"
     ensure
       #fileHtml.close unless fileHtml.nil?
     end

     text
   end

     # Get the elements of the code in html format. Return a string with elements in html.
     #
     # Example:
     #   >> CodeTerminator::Html.print_elements([#<Nokogiri::XML::Element:0x3fe31dc42bfc name="h1" children=[#<Nokogiri::XML::Text:0x3fe31dc42b70 "hola evelin">]>, #<Nokogiri::XML::Text:0x3fe31dc42b70 "hola evelin">])
     #   => "name = h1<br><hr>name = text<br>content = hola evelin<br><hr>"
     #
     # Arguments:
     #   elements: (Array)

   def print_elements(elements)
     text = ""
     elements.each do |child|
       text << "name = " + child.name + "<br>"
       text << "content = " + child.text + "<br>" if child.text?
       child.attribute_nodes.each do |child_attribute|
          text << child.name + " attribute = " + child_attribute.name + " - " + child_attribute.value + "<br>"
       end
       text << "<hr>"
     end
     text
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
     #@elements = Html::PrintElements.call(elements)

     elements.each do |element|
       if element.name == "text"
         #code if element is text
       else
         if code.css(element.name).length == 0
           html_errors << element.name + " not exist"
         else
           element.attribute_nodes.each do |element_attribute|
             if !code.css(element.name).attribute(element_attribute.name).nil?
               if code.css(element.name).attribute(element_attribute.name).value != element_attribute.value
                 html_errors << element_attribute.name + " not is the same value " + element_attribute.value
               end
             else
               html_errors << element_attribute.name + " not exist"
             end
           end
         end
       end
     end
     html_errors
   end

   private

   def add_children(parent)
     parent.children.each do |child|
       @tags.push(child)
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
