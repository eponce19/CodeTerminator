require 'Nokogiri'
require 'Crass'
require 'css_parser'
require 'active_support/core_ext/string/filters'

class CodeTerminator::Css

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
     #  IMPORTANT DELETE <STYLE> tag from the source


   def get_elements(source)
    #  reader = Nokogiri::HTML(File.open(source))
    #  reader = remove_empty_text(reader)
    #  reader.at('style').children.each do |child|
    #    @tags.push(child)
    #    add_children(child) if child.children.any?
    #  end
      reader = read_file(source)
      # reader = reader.tr('\<style>','')
      # reader = reader.tr('\</style>','')
      parser = Crass.parse(reader)
      errors = parser.pop
      p errors
      elements = Array.new
      selector = ""

      parser.each do |node|
        if !node[:selector].nil?
          selector = node[:selector][:value]
          elements << {:selector => selector}
        end
        if !node[:children].nil?
          node[:children].each do |children|
            if children.has_value?(:property)
              elements << {:selector => selector, :property => children[:name], :value => children[:value]}
            end
          end
        end
      end

      elements

   end

     # Validate if the syntax is correct. Return an array with Nokogiri errors.
     #
     # Example:
     #   >> CodeTerminator::Html.validate_syntax("<h1>Hola Mundo!</h1")
     #   => [#<Nokogiri::XML::SyntaxError: expected '>'>]
     #
     # Arguments:
     #   code: (String)

    #  IMPORTANT Only check the syntax inside the <></>, remember to check th syntax inside the style node

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
     #  IMPORTANT print the elements that are in #cdata-section inside <style>

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
   #IMPORTANT this doesnt work because get_elements havent fixed yet.

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

   def match(source,code)
     #source = "exercises/test.css"
     #code = " a.hover { color: yellow; } body { background-color: lightblue; color: blue; } "
     elements = get_elements(source)
     css_errors = Array.new
     parser = CssParser::Parser.new

     parser.load_string!(code)
     elements.each do |e|
       item = e[:selector]
       if !e[:property].nil?
         property = e[:property] + ": " + e[:value]
         parser_array = parser.find_by_selector(item)
         if parser_array.any?
           parser_property = parser_array[0].split(";")
           parser_property.each {|a| a.strip! if a.respond_to? :strip! }
           if !parser_property.include?(property)
             css_errors << "not the same property " + property + " in selector " + item
           end
         else
          css_errors << "property "+ property + " not found in " + item
         end
       end
     end
     css_errors
   end

   private


  #end

end
