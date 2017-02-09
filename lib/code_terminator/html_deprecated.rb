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
       if reader.at('body')
         node = Hash.new
         node[:parent] = "html"
         node[:tag] = "body"
         @elements << node

         reader.at('body').attribute_nodes.each do |element_attribute|
           node = Hash.new
           node[:parent] = "html"
           node[:tag] = "body"
           node[:attribute] = element_attribute.name if element_attribute.name
           node[:value] = element_attribute.value if element_attribute.value
           node[:pointer] = element_attribute.pointer_id
           @elements << node
         end
      end
      #end search

      #search elements from head section
     if reader.at('head')
       node = Hash.new
       node[:parent] = "html"
       node[:tag] = "head"
       @elements << node
       reader.at('head').children.each do |child|
         if child.attribute_nodes.empty?
           node = Hash.new
           node[:parent] = "head"
           node[:tag] = child.name
           node[:content] = child.text if child.text or child.comment?
           node[:pointer] = child.pointer_id
           node[:parent_pointer] = child.parent.pointer_id

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
             node[:attribute] = element_attribute.name if element_attribute.name
             node[:value] = element_attribute.value if element_attribute.value
             node[:pointer] = element_attribute.pointer_id
             node[:parent_pointer] = child.pointer_id
             @elements << node
           end
         end
         add_children(child) if child.children.any?
       end
    end
    #end search elements

    #search elements inside body (children)
    if reader.at('body')
      reader.at('body').children.each do |child|
        if child.attribute_nodes.empty?
          node = Hash.new
          node[:parent] = "body"
          node[:tag] = child.name
          node[:content] = child.text if child.text? or child.comment?
          node[:pointer] = child.pointer_id
          node[:parent_pointer] = child.parent.pointer_id
          @elements << node
        else
          node = Hash.new
          node[:parent] = "body"
          node[:tag] = child.name
          node[:content] = child.text if child.text? or child.comment?
          node[:pointer] = child.pointer_id
          node[:parent_pointer] = child.parent.pointer_id
          @elements << node
          child.attribute_nodes.each do |element_attribute|
            node = Hash.new
            node[:parent] = "body"
            node[:tag] = child.name
            node[:attribute] = element_attribute.name if element_attribute.name
            node[:value] = element_attribute.value if element_attribute.value
            node[:pointer] = element_attribute.pointer_id
            node[:parent_pointer] = child.pointer_id
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
       text << "parent = " + child[:parent] + "<br>" if child[:parent]
       text << "tag = " + child[:tag] + "<br>" if child[:tag]
       text << "attribute = " + child[:attribute] + "<br>" if child[:attribute]
       text << "value = " + child[:value] + "<br>" if child[:value]
       text << "content = " + child[:content] + "<br>" if child[:content]
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
     @html_errors = Array.new
     html_errors = @html_errors

     code = Nokogiri::HTML(code)

     elements = get_elements(source)


     exist_in_body = Array.new
     exist_value = Array.new

     error_elements = Array.new

     elements_count = Array.new

     error333 = nil

     #lista de relaciones entre tags y elementos
     css_code_checked = Array.new


     elements.each do |e|
       p "element " + e.to_s
       p "select ---"
      #  p elements_count

       if e[:attribute].nil?
           #tag con el mismo parent pointer no se repite ni se cuenta
          #  p "element count"
          #  elements_count.select {|element| element[:parent_pointer].to_s == e[:parent_pointer].to_s && element[:tag].to_s == e[:tag]}


          #  if elements_count.select {|element| element[:parent_pointer].to_s == e[:parent_pointer].to_s && element[:tag].to_s == e[:tag]}.count < 1
             the_element = Hash.new
             the_element[:tag] = e[:tag]
             the_element[:pointer] = e[:pointer]
             the_element[:parent_pointer] = e[:parent_pointer]
             the_element[:count] = 0
             elements_count << the_element
          #  end
        end

       item = e[:tag]

       if item == "text" or item == "comment"
        #  Check the text
         if e[:content]
           if code.css(e[:parent]).count < 2
             if code.css(e[:parent]).class == Nokogiri::XML::NodeSet
               #look for children elements with texts or comments
               look_comment_or_text(code,e)
             end
           else
             #check if parent tag of the user code has text apart from the children tags
             look_parent_text(code,e)
           end
          end
         #end if content is null
        else
       #item class is different to text or comment

p "code_checked"
p css_code_checked
p "elements count"
p elements_count
p "elements"
p elements
p "code css"
p code.css(e[:tag])

       code.css(e[:tag]).each do |tag|
         p "tag " + tag.to_s
         tag_element = nil
        #  e_check = css_code_checked.select {|element| element[:original_pointer].to_s == e[:pointer].to_s }
         # p "echeck " + e_check.to_s
         e_check2 = css_code_checked.select {|element| element[:pointer].to_s == tag.pointer_id.to_s }

         #original_pointer es el pointer del elemento e[]
         #busca si el original_pointer esta en la lista de relaciones
         #busca si el pointer del tag esta en la lista de relaciones
         #cuando un original pointer o un pointer esta en la lista de relaciones, ya no puede volver a ser ingresado en la lista
         #si el original pointer ya esta en la lista de relaciones, ya no es necesario volver a checarlo
         check_original_pointer = css_code_checked.select {|element| element[:original_pointer].to_s == e[:pointer].to_s }

         check_add_pointer = css_code_checked.select {|element| element[:pointer].to_s == tag.pointer_id.to_s }
        #  p "check_add " + check_add_pointer.to_s
         #look for same tags in code
        #  p "elements_count"
        #  p elements_count

           if check_original_pointer.count == 0
          #  p "pasa"
          # #  if tag.attributes.nil?
          # #    p "CON ATRIBUTOS"
          # #  else
          # #  p elements_count.to_s
          #  p "element " +e[:tag].to_s
          #  p "e pointer "+e[:pointer].to_s
          #  p "e parent pointer "+e[:parent_pointer].to_s

          # end
          #  if check_add_pointer.count < 1
             element_checked = Hash.new
             element_checked[:pointer] = tag.pointer_id
             element_checked[:tag] = e[:tag]
             element_checked[:original_pointer] = e[:pointer]
             element_checked[:original_parent_pointer] = e[:parent_pointer]
             css_code_checked << element_checked
           end
            #  the_element = elements_count.select {|element| element[:tag].to_s == e[:tag].to_s && element[:parent_pointer].to_s == e[:parent_pointer].to_s}.first
            # the_element = elements_count.select {|element| element[:tag].to_s == e[:tag].to_s && element[:pointer].to_s == e[:parent_pointer].to_s}.first
            p "the element"
            if e[:tag]!="head" &&  e[:tag]!="html" && e[:tag]!="body"
              the_element = elements_count.select {|element| element[:tag].to_s == e[:tag].to_s && element[:pointer].to_s == e[:pointer].to_s}.first
              the_element[:count] += 1 if the_element
            else
              the_element = elements_count.select {|element| element[:tag].to_s == e[:tag].to_s}.first
              the_element[:count] += 1 if the_element
            end
            #  p "the element " + the_element.to_s

          #  end
        #  end
        #  end
        # p "checked = " + elements_count.to_s

       if code.css(e[:tag]).length > 0

         #tag es el elemento reccorrido en el codigo
         #e es el elemento original
         #elementscount son los elementos que existen en codigo y original

        #  if tag_element
         if e[:attribute]

          #  p "e --- " + e[:tag].to_s
          #  p "e pt--- " + e[:pointer].to_s
          #  p "e parent pt--- " + e[:parent_pointer].to_s
          #  p "e attribute --- " + e[:attribute].to_s


          #  if tag.attribute(e[:attribute])
            #  p "elements count = " + css_code_checked.to_s
             tag_element = css_code_checked.select {|element| element[:pointer].to_s == tag.pointer_id.to_s && element[:original_pointer] == e[:pointer] }.first
            #  p "tag --" + tag.name.to_s
            #  p "tag --" + tag.to_s
            #  p "tag parent -- " + tag.parent.name.to_s
            #  p "tag pointer -- " + tag.pointer_id.to_s
            #  p "tag parent pointer -- " + tag.parent.pointer_id.to_s
            #  p "tag attribute -- " + tag.attribute(e[:attribute]).to_s
            #   p "parent_element --- " + tag_element.to_s
          #  else
            # end

          #  Check the tag's attributes
          if tag.attribute(e[:attribute]).nil?
            if tag_element
            #  p "attribute element " + e[:attribute].to_s
            #  p "attribute tag " + tag.attribute(e[:attribute]).name.to_s
            #  if e[:attribute] != tag.attribute(e[:attribute]).name
               html_errors << new_error(element: e, type: 334, description: "`<#{e[:tag]}>` should have an attribute named #{e[:attribute]}")
            #  end
           end
           else
             if tag.attribute(e[:attribute]).value != e[:value]
                 exist_in_body << false
                #  p "value " + e[:value]
                tag_attribute = tag.attribute(e[:attribute]).name
                tag_attribute_value = tag.attribute(e[:attribute]).value
                # p "type " + e[:tag] + " with attribute " + e[:attribute] + " value " + e[:value]
                # Check if the img have attribute src and value is null, the user can write whatever image he wants
                # p exist_value
                 if !(e[:tag] == "img" && (e[:attribute] == tag_attribute) && e[:value] == "")
                   if (!exist_value.include? tag_attribute_value and !exist_value.include? e[:value])
                     exist_in_body << false
                      error333 = new_error(element: e, type: 333, description: "Make sure that the attribute #{e[:attribute]} in `<#{e[:tag]}>` has the value #{e[:value]}")
                    end
                    # html_errors << error333 if error333
                 else

                 end
               else
              #  p "add code_checked"
              exist_value << e[:value]
              #  css_code_checked << element_checked
               exist_in_body << true
             end
           end
          # end


        #  p "respond" + tag.parent.to_s
        #  Check that tags exist within parent tags
        if tag.first.respond_to? :parent

          # p  "check if exists in parent tags"

          # e_check4 = css_code_checked.select {|element| element[:pointer].to_s == e[:pointer].to_s }
          # e_check5 = css_code_checked.select {|element| element[:target_parent_pointer].to_s == e[:parent_pointer].to_s }

         if (tag.count < 2 && tag.first)
           if tag.first.parent.name != e[:parent]
             html_errors << new_error(element: e, type: 440, description: "Remember to add the `<#{e[:tag]}>` tag inside `<#{e[:parent]}>`")
           end
         else
           exist_in_parent = false
           tag.each do |code_css|
             exist_in_parent = true if code_css.parent.name == e[:parent]
           end
           html_errors << new_error(element: e, type: 440, description: "Remember to add the `<#{e[:tag]}>` tag inside `<#{e[:parent]}>`") if !exist_in_parent
          end
        end

        end

      end

    end

      # end #end tag

       if exist_in_body && !exist_in_body.include?(true) && error333
         html_errors << error333
       end

      #  if exist_in_body && !exist_in_body.include?(true) && error333
      #    html_errors << error333
      #  end

       exist_in_body = []
       error333 = nil
      #  exist_value = []

      end

     end

      # p "elements_count = " + elements_count.group_by{|h| h[:parent_pointer]}.to_s

      # p "elements_count2 = "
      grouped_elements = elements_count.select {|element| element[:count] > 0}.group_by { |s| [s[:parent_pointer], s[:tag]] }

     grouped_elements.each do |x|
       #filtrar por parent
       #tag_count = code.css(x[:tag]).length
      tag_count = elements.select {|element| element[:parent_pointer].to_s == x[0][0].to_s && element[:tag].to_s == x[0][1]}
      # p "group="+tag_count.group_by{|h| h[:parent_pointer]}.values.to_s
      # p result=Hash[tag_count.group_by{|x|x}.map{|k,v| [k,v.size]}]
      p "tag" + x.to_s
      p "tag count " + tag_count.count.to_s
      p "grouped" + x.to_s
      p "grouped count " + x[1].first[:count].to_s
      (p "div count " + x[1][0].count.to_s) if x[0][1]=="div"

      # p tag_count = elements.select {|element| element[:pointer].to_s == x[:pointer].to_s && element[:tag].to_s == x[:tag]}.count
      #  p x[:tag]!="body"
       if tag_count.count >= 1 && !(x[0][1]=="text" || x[0][1]=="comment")
      # if tag_count >= 1 && !(x[:tag]!="div")
          if x[0][1]=="div"
            if x[1][0].count.to_i < tag_count.count
              html_errors << new_error(element: x[0][1], type: 404, description:  "Remember to add the `<#{x[0][1]}>` tag")
            end
          else
             if x[1].first[:count] < tag_count.count
               html_errors << new_error(element: x[0][1], type: 404, description:  "Remember to add the `<#{x[0][1]}>` tag")
             end
           end
       end
     end

    #  grouped_elements_null = elements_count.select {|element| element[:count] == 0}.group_by { |s| [s[:parent_pointer], s[:tag]] }
     #
    #  grouped_elements_null.each do |nulls|
    #    if !(nulls[0][1]=="body" || nulls[0][1]=="head" || nulls[0][1]=="text" || nulls[0][1]=="comment")
    #   # if tag_count >= 1 && !(x[:tag]!="div")
    #     #  if x[1].count < tag_count.count
    #        html_errors << new_error(element: nulls[0][1], type: 404, description:  "Remember to add the `<#{nulls[0][1]}>` tag")
    #     #  end
    #    end
    #  end
     p elements_count
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
          node[:pointer] = child.pointer_id
          node[:parent_pointer] = child.parent.pointer_id
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
           node[:pointer] = element_attribute.pointer_id
           node[:parent_pointer] = child.pointer_id
           @elements << node
         end
       end

       add_children(child) if child.children.any?
     end
   end

   def remove_empty_text (reader)
     if reader.at('head')
     reader.at('head').children.each do |child|
       if child.text
         child.remove if child.content.to_s.squish.empty? && child.class == Nokogiri::XML::Text
       end
        check_children(child) if child.children.any?
     end
    end
      if reader.at('body')
     reader.at('body').children.each do |child|
       if child.text
         child.remove if child.content.to_s.squish.empty? && child.class == Nokogiri::XML::Text
       end
        check_children(child) if child.children.any?
     end
    end
     reader
   end

   def check_children(parent)
     parent.children.each do |child|
       if child.text
         child.remove if child.content.to_s.squish.empty? && child.class == Nokogiri::XML::Text
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


#methods of match
   def look_comment_or_text(code,e)
     error330 = nil
     text_found = false
     @comment_found = false if e[:tag] == "comment"

     #look for comments or text in code
     #code, e
     if code.css(e[:parent]).children.any?
      #look for comments and text in children of body
      # code, e
      #save
      #return
      code.css(e[:parent]).children.each do |node_child|
        #if class of the node is a comment, look in the code
        # @e, node_child
        #save error330
        #return true (flag)
        if node_child.class == Nokogiri::XML::Comment
          error330 = new_error(element: e, type: 330, description: "The text inside the comment should be #{e[:content]}") if e[:content].strip != "" && node_child.text.strip! != e[:content].strip!
          @comment_found = true
        end

        #if class of node is text and element is not a comment
        #@e, node_child
        #save a error330, text_found
        #return true (flag)
        if node_child.class == Nokogiri::XML::Text && e[:tag] != "comment"
          node_child.text.strip != e[:content].strip ? error330 = new_error(element: e, type: 330, description: "The text inside `<#{e[:parent]}>` should be #{e[:content]}") : text_found = true
        end
      end #each

      else
         #validate if comment exist and has the expected content in body
         #code, @e
         #save @comment_found, text_found
         if code.css(e[:parent]).text.strip != e[:content].strip
           if e[:tag] == "comment"
             error330 = new_error(element: e, type: 330, description: "The text inside the comment should be #{e[:content]}")
             @comment_found = true
           else
             error330 = new_error(element: e, type: 330, description: "The text inside `<#{e[:parent]}>` should be #{e[:content]}")
           end
          else
            text_found = true
          end
       end #end if parent has children

       #throw errors of comment or text
       #if comment not found, throw error
        if (defined? @comment_found) && !@comment_found
          @html_errors << new_error(element: e, type: 404, description:  "Remember to add the comment tag")
          remove_instance_variable(:@comment_found) if !@comment_found
        end

       if !text_found && error330
         @html_errors << error330
         error330 = nil
       end
       #end throw errors
   end #end look_comment_or_text

   def look_parent_text(code,e)
     exist = false
     #look for text in parent, if found check flag true
     code.css(e[:parent]).each do |code_css|
       if code_css.text == e[:content]
         exist = true
       end
     end
     if !exist
      @html_errors << new_error(element: e, type: 330, description: "The text inside `<#{e[:parent]}>` should be #{e[:content]}")
     end
   end


  #end

end
