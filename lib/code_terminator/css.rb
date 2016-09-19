require 'Nokogiri'
require 'Crass'
require 'css_parser'
require 'active_support/core_ext/string/filters'

class CodeTerminator::Css

  def initialize(args = {})
    @code = args[:code]
    @source = args[:source]
    @tags = Array.new

    args[:source_type] ||= "file"
    @source_type = args[:source_type]
  end

    # Create a CSS file with the code of the editor. Return a boolean that indicate if the file was created or not.
    #
    # Example:
    #   >> CodeTerminator::Css.new_file("test.css", "<style> body { background-color: lightblue; }</style>")
    #   => true
    #
    # Arguments:
    #   source: (String)
    #   code: (String)

   def new_file(source,code)
     fileCss = File.new(source, "w+")
     result = true
     begin
       fileCss.puts code
     rescue
       result = false
     ensure
       fileCss.close unless fileCss.nil?
     end
     #return true if file was succesfully created
     result
   end


     # Get html elements of a css file. Return a array of selectors with their properties and values.
     #
     # Example:
     #   >> CodeTerminator::Css.get_elements("test.css")
     #   => [{:selector=>"body"}, {:selector=>"body", :property=>"background-color", :value=>"lightblue"}, {:selector=>"body", :property=>"color", :value=>"green"}]
     #
     # Arguments:
     #   source: (String)
     #
     # Fixes:
     #   IMPORTANT DELETE <STYLE> tag from the source


   def get_elements(source)
      reader = read_file(source)
      parser = Crass.parse(reader)
      errors = parser.pop
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

     # Validate if the syntax is correct. If is valid return boolean true.
     #
     # Example:
     #   >> CodeTerminator::Html.validate_syntax("body { background-color: lightblue; }")
     #   => true
     #
     # Arguments:
     #   code: (String)
     #
     # Fixes:
     #   IMPORTANT Method not validate <STYLE> tag from the code

   def validate_syntax(code)
     errors = Array.new
     tree = Crass.parse(code)
     last = tree.length
     if !tree[last-1].nil?
     nodes = tree[last-1][:children]
      if !nodes.nil?
        nodes.each do |children|
          if children[:node].to_s == "error"
            errors[0] = "error"
          end
        end
      #else
        #valid = false
      end
    else
      errors[0] = "error"
    end
    errors
  end

     # Read a css file. Return a string with the text of the file.
     #
     # Example:
     #   >> CodeTerminator::Css.read_file("test.css")
     #   => "body { background-color: lightblue; }"
     #
     # Arguments:
     #   source: (String)

   def read_file(source)
     if @source_type == "url"
       fileCss = open(source).read
     else
       fileCss = File.open(source, "r")
     end

     text = ""
     begin
       fileCss.each_line do |line|
         text << line
       end
       fileCss.close
     rescue
       text = false
     ensure
       #fileHtml.close unless fileHtml.nil?
     end

     text
   end

     # Get the elements of the code in css format. Return a string with elements in css.
     #
     # Example:
     #   >> CodeTerminator::Css.print_elements("exercises/hola_mundo.css" )
     #   => "selector = body<br><hr>selector = body<br>property = background-color<br>value = lightblue<br><hr>"
     #
     # Arguments:
     #   elements: (Array)


   def print_elements(source)
     elements = get_elements(source)
     text = ""
     elements.each do |child|
       text << "selector = " + child[:selector] + "<br>"
       text << "property = " + child[:property] + "<br>" if !child[:property].nil?
       text << "value = " + child[:value] + "<br>" if !child[:value].nil?
       text << "<hr>"
     end
     text
   end

   # Get the instructions to recreate the html code. Return an array with strings .
   #
   # Example:
   #   >> CodeTerminator::Css.get_instructions(file.get_elements("exercises/test.css"))
   #   => [["Create the selector body", "In the selector body add the property 'background-color' with value 'yellow' "]
   #
   # Arguments:
   #   instructions: (Array)

   def get_instructions(source)
     elements = get_elements(source)
     text = ""
     instructions = Array.new
     elements.each do |child|
       if child[:property].nil?
         text << "Create the selector " + child[:selector]
       else
         text << "In the selector " + child[:selector] + " add the property '"  + child[:property] + "'"  if !child[:property].nil?
         text << " with value '" + child[:value] + "' " if !child[:value].nil?
       end
       instructions.push(text)
       text = ""
     end
     instructions
   end



   # Match if the code have the same elements than the exercise. Return an array with the mismatches.

   # Example:
   #
   #   test.css
   #   => body { background-color: lightblue; }
   #
   #   >> CodeTerminator::Css.match("test.css","body {background-color: blue; }")
   #   => [{:element=>{:selector=>"body", :property=>"background-color", :value=>"yellow"}, :type=>111, :description=>"not the same property background-color: yellow in selector body"}]
   #
   # Arguments:
   #   source: (String)
   #   code: (String)
   #
   # Fix: Add <style> tag in the compare

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

         parser_array = parser.find_by_selector(item)
         if parser_array.any?
           parser_property = parser_array[0].split(";")
           parser_property.each {|a| a.strip! if a.respond_to? :strip! }

           if e[:value]==""
             property = e[:property] + ": "
             if parser_property.empty? { |s| s.include?(property) }
               css_errors << new_error(element: e, type: 111, description: "not the same property " + property + " in selector " + item)
             end
           else
             property = e[:property] + ": " + e[:value]
             if !parser_property.include?(property)
               css_errors << new_error(element: e, type: 111, description: "not the same property " + property + " in selector " + item)
             end
           end

         else
           node = Hash.new
           css_errors << new_error(element: e, type: 101, description:  "property "+ property + " not found in " + item)
         end
       end
     end
     css_errors
   end

   private

   def new_error(args = {})
     element = args[:element]
     type = args[:type]
     description = args[:description]
     node = Hash.new
     node[:element] = element
     node[:type] = type
     node[:description] =  description
     node
   end
  #end

end
