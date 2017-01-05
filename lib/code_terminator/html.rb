require 'active_support/core_ext/string/filters'

class CodeTerminator::Html

  def initialize(args = {})
    @code = args[:code]
    @source = args[:source]
    @tags = Array.new
    @elements = Array.new

    args[:source_type] ||= "file"
    @source_type = args[:source_type]
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
     #How to read if is an url
     if @source_type == "url"
       reader = Nokogiri::HTML(open(source).read)
     else
       reader = Nokogiri::HTML(File.open(source))
     end
     #remove empty spaces from reader
     reader = remove_empty_text(reader)
     node = Hash.new
     node[:parent] = ""
     node[:tag] = "html"
     @elements << node

     #search elements from body section
       if !reader.at('body').nil?
         node = Hash.new
         node[:parent] = "html"
         node[:tag] = "body"
         @elements << node

         reader.at('body').attribute_nodes.each do |element_attribute|
           node = Hash.new
           node[:parent] = "html"
           node[:tag] = "body"
           node[:attribute] = element_attribute.name if !element_attribute.name.nil?
           node[:value] = element_attribute.value if !element_attribute.value.nil?
           @elements << node
         end
      end
      #end search

      #search elements from head section
     if !reader.at('head').nil?
       node = Hash.new
       node[:parent] = "html"
       node[:tag] = "head"
       @elements << node
       reader.at('head').children.each do |child|
         if child.attribute_nodes.empty?
           node = Hash.new
           node[:parent] = "head"
           node[:tag] = child.name
           node[:content] = child.text if !child.text.nil? or child.comment?
           @elements << node
         else
           child.attribute_nodes.each do |element_attribute|
             node = Hash.new
             node[:parent] = "head"
             if child.name == "#cdata-section"
               node[:tag] = "text"
             else
               node[:tag] = child.name
             end
             # node[:tag] = ( ? "text", child.name)
             node[:content] = child.text if !child.text.nil?
             node[:attribute] = element_attribute.name if !element_attribute.name.nil?
             node[:value] = element_attribute.value if !element_attribute.value.nil?
             @elements << node
           end
         end
         add_children(child) if child.children.any?
       end
    end
    #end search elements

    #search elements inside body (children)
    if !reader.at('body').nil?
      reader.at('body').children.each do |child|
        if child.attribute_nodes.empty?
          node = Hash.new
          node[:parent] = "body"
          node[:tag] = child.name
          node[:content] = child.text if child.text? or child.comment?
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
     end
     #end search elements

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
     if @source_type == "url"
       fileHtml = open(source).read
     else
       fileHtml = File.open(source, "r")
     end

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
     #   >> CodeTerminator::Html.print_elements("exercises/hola_mundo.html" )
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

   def get_instructions(source)
     elements = get_elements(source)
     text = ""
     instructions = Array.new
     elements.each do |child|
       if child[:tag]!="text"
         text << "Add the tag " + child[:tag]
         text << " in "  + child[:parent]  if !child[:parent].nil?
         text << " with an attribute '" + child[:attribute] + "' " if !child[:attribute].nil?
         text << " with value '" + child[:value] + "' " if !child[:value].nil?
       elsif child[:tag] == "comment"
        text << " In " + child[:tag]+ " add the text '" + child[:content]  + "' "  if !child[:content].nil?
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

     exist_in_body = Array.new

     error333 = nil

     elements.each do |e|

      p item = e[:tag]

       if item == "text" or item == "comment"

        #  Check the text
         if !e[:content].nil?
           if code.css(e[:parent]).count < 2
             if code.css(e[:parent]).class == Nokogiri::XML::NodeSet
               text_found = false
               comment_found = false if item == "comment"
               error330 = nil
               if code.css(e[:parent]).children.any?
                 code.css(e[:parent]).children.each do |node_child|

                  #  p "node child " + node_child.class.to_s
                  #  p "item " + item

                     if item == "comment" && node_child.class == Nokogiri::XML::Comment
                       comment_found = true
                     end

                   if node_child.class != Nokogiri::XML::Element
                     #embebed code
                     #if code.css(e[:parent]).text != e[:content]

                     if node_child.text.strip != e[:content].strip
                       if item == "comment"
                         #  if comment isn't present in the code, mark add tag
                         if e[:content].strip != ""
                           error330 = new_error(element: e, type: 330, description: "The text inside the comment should be #{e[:content]}")
                         end
                       else
                         error330 = new_error(element: e, type: 330, description: "The text inside `<#{e[:parent]}>` should be #{e[:content]}")
                       end
                     else
                       text_found = true
                     end
                     #end embebed code
                   end
                 end

                 if !(defined? comment_found).nil?
                   if !comment_found
                     html_errors << new_error(element: e, type: 404, description:  "Remember to add the `<#{e[:tag]}>` tag")
                   end
                 end
                 #end each
                else
                  if item == "comment"
                    html_errors << new_error(element: e, type: 404, description:  "Remember to add the `<#{e[:tag]}>` tag")
                  end
                  if code.css(e[:parent]).text.strip != e[:content].strip
                  # p "text of node: " + code.css(e[:parent]).text
                    if item == "comment"
                      error330 = new_error(element: e, type: 330, description: "The text inside the comment should be #{e[:content]}")
                    else
                      error330 = new_error(element: e, type: 330, description: "The text inside `<#{e[:parent]}>` should be #{e[:content]}")
                    end
                  else
                    text_found = true
                  end
                end
                #end if parent has children
                # if !comment_found
                #   html_errors << new_error(element: e, type: 404, description:  "Remember to add the `comment` tag")
                # end

               if !text_found && !error330.nil?
                 html_errors << error330
                 error330 = nil
               end
             end
             #end if parent is nodeset
           else
             exist = false
             code.css(e[:parent]).each do |code_css|
               #if code_css.at_css(e[:tag]).parent.name == e[:parent]
               p "text content: " + code_css.text
                 if code_css.text == e[:content]
                   exist = true
                 end
               #end
             end
             if !exist
              html_errors << new_error(element: e, type: 330, description: "The text inside `<#{e[:parent]}>` should be #{e[:content]}")
             end
           end
           #end if parent < 2

         end
         #end if content is null

       else
       #item class is different to text or comment

       if code.css(e[:tag]).length > 0

        code.css(e[:tag]).each do |tag|

         if !e[:attribute].nil?
          #  Check the tag's attributes
           if tag.attribute(e[:attribute]).nil?
             html_errors << new_error(element: e, type: 334, description: "`<#{e[:tag]}>` should have an attribute named #{e[:attribute]}")
           else
             if tag.attribute(e[:attribute]).value != e[:value]
                 exist_in_body << false
                #  p "type " + e[:tag] + " with attribute " + e[:attribute] + " value " + e[:value]
                # Check if the img have attribute src and value is null, the user can write whatever image he wants
                 if !(e[:tag] == "img" && e[:attribute] == "src" && e[:value] == "")
                   error333 = new_error(element: e, type: 333, description: "Make sure that the attribute #{e[:attribute]} in `<#{e[:tag]}>` has the value #{e[:value]}")
                 end
             else
               exist_in_body << true
             end

           end
         end

        #  Check that tags exist within parent tags
        if tag.first.respond_to? :parent

         if tag.count < 2 && !tag.first.nil?
           if tag.first.parent.name != e[:parent]
             html_errors << new_error(element: e, type: 440, description: "Remember to add the `<#{e[:tag]}>` tag inside `<#{e[:parent]}>`")
           end
         else
          exist_in_parent = false
           tag.each do |code_css|
              if code_css.parent.name == e[:parent]
                exist_in_parent = true
              end
            end
            if !exist_in_parent
              html_errors << new_error(element: e, type: 440, description: "Remember to add the `<#{e[:tag]}>` tag inside `<#{e[:parent]}>`")
            end
         end
        end
        end

       else
         #  Check that the tag is present
          if code.at_css(e[:tag]).nil?
            html_errors << new_error(element: e, type: 404, description:  "Remember to add the `<#{e[:tag]}>` tag")
          end
       end

       if !exist_in_body.empty? && !exist_in_body.include?(true) && !error333.nil?
         html_errors << error333
       end
       exist_in_body = []

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
          # node[:tag] = child.name
          if child.name == "#cdata-section"
            node[:tag] = "text"
          else
            node[:tag] = child.name
          end
          node[:content] = child.text if !child.text.nil? and child.class!=Nokogiri::XML::Element
          @elements << node
       else
         child.attribute_nodes.each do |element_attribute|
           node = Hash.new
           node[:parent] = parent.name
          #  node[:tag] = child.namecode
           if element_attribute.name == "#cdata-section"
             node[:tag] = "text"
           elsif element_attribute.name == "href"
             node[:tag] = child.name
           else
             node[:tag] = element_attribute.name
           end
           node[:attribute] = element_attribute.name if !element_attribute.name.nil?
           node[:value] = element_attribute.value if !element_attribute.value.nil?
           @elements << node
         end
       end

       add_children(child) if child.children.any?
     end
   end

   def remove_empty_text (reader)
     if !reader.at('head').nil?
     reader.at('head').children.each do |child|
       if !child.text.nil?
         child.remove if child.content.to_s.squish.empty? && child.class == Nokogiri::XML::Text
       end
        check_children(child) if child.children.any?
     end
    end
      if !reader.at('body').nil?
     reader.at('body').children.each do |child|
       if !child.text.nil?
         child.remove if child.content.to_s.squish.empty? && child.class == Nokogiri::XML::Text
       end
        check_children(child) if child.children.any?
     end
    end
     reader
   end

   def check_children(parent)
     parent.children.each do |child|
       if !child.text.nil?
         child.remove if child.content.to_s.squish.empty?
       end
       check_children(child) if child.children.any?
     end
   end

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
