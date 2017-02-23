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
     if reader.css('html').any?
       node = Hash.new
       node[:parent] = ""
       node[:tag] = "html"
       node[:pointer] = reader.css('html').first.pointer_id
       @elements << node
     end

     #search elements from body section
       if reader.at('body')
         node = Hash.new
         node[:parent] = "html"
         node[:tag] = "body"
         node[:pointer] = reader.css('body').first.pointer_id
         node[:parent_pointer] = reader.css('html').first.pointer_id
         @elements << node

         reader.at('body').attribute_nodes.each do |element_attribute|
           node = Hash.new
           node[:parent] = "html"
           node[:tag] = "body"
           node[:attribute] = element_attribute.name if element_attribute.name
           node[:value] = element_attribute.value if element_attribute.value
           node[:pointer] = element_attribute.pointer_id
           node[:parent_pointer] = reader.css('html').first.pointer_id
           @elements << node
         end
      end
      #end search

      #search elements from head section
     if reader.at('head')
       node = Hash.new
       node[:parent] = "html"
       node[:tag] = "head"
       node[:pointer] = reader.css('head').first.pointer_id
       node[:parent_pointer] = reader.css('html').first.pointer_id
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
             node[:content] = child.text if child.text
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
     code = Nokogiri::HTML(code)
     @elements = get_elements(source)

     @elements.each do |e|
       p css_string = build_css(e,'').strip

       #search_attribute()
       if e[:attribute]
        #  search_attribute = code.css(css_string).first
        #  if !search_attribute
        #    @html_errors << new_error(element: e, type: 334, description: "`<#{e[:tag]}>` should have an attribute named #{e[:attribute]} with the value #{e[:value]}")
        #  end

       #search_text()
      elsif e[:tag] == "text" || e[:tag] == "comment"
         element_name = e[:tag]=="comment" ? "comment":e[:parent]
         search_elements = code.css(css_string)
         if e[:content].strip != ""
           element = search_elements.select{|hash| hash.text.strip == e[:content].strip}
           if element.empty?
             @html_errors << new_error(element: e, type: 330, description: "The text inside `<#{element_name}>` should be #{e[:content]}")
           end
         end
      #search_element()
       else

         search_element = code.css(css_string).first
         if !search_element
            @html_errors << new_error(element: e[:tag], type: 404, description:  "Remember to add the `<#{e[:tag]}>` tag in " + css_string.chomp(e[:tag]))
        #  else
        #    if !are_all_elements(code,e[:tag], css_string)
        #     #  @html_errors << new_error(element: e[:tag], type: 404, description:  "Remember to add the `<#{e[:tag]}>` tag.")
        #    end
          end

       end

     end

     count_elements(code)
     search_attribute_value(code)

     p @html_errors
   end



   private

   def build_css(element, css)
     if !element[:parent].empty?
       if !element[:attribute]
          if element[:tag]=="comment"
           css += "//comment()"
          else
            parent = @elements.select{|hash| hash[:pointer].to_s == element[:parent_pointer].to_s}.first
            parent_css = parent[:tag].to_s if parent
            css += parent_css

             parent_attributes = @elements.select{|hash| hash[:parent_pointer].to_s == element[:parent_pointer].to_s && hash[:attribute]}
             parent_attributes.each do |par_attr|
               css += css_attribute_type(par_attr)
            end
            css += " "
            css += element[:tag].to_s + " " if element[:tag] != "text"
          end

        else

           search_attribute = @elements.select{|hash| hash[:parent_pointer].to_s == element[:parent_pointer].to_s && hash[:attribute].to_s == element[:attribute]}.first
           css += search_attribute[:tag].to_s
           attribute_css = css_attribute_type(search_attribute) if search_attribute
           css += attribute_css

        end
      else
        css += element[:tag].to_s + " " if element[:tag] != "text"
      end
       css
   end

   def css_attribute_type(element)
     case element[:attribute]
     when "id"
       css_symbol = '#'
       css = css_symbol.to_s + element[:value].to_s
     when "class"
       css_symbol = '.'
       css = css_symbol.to_s + element[:value].to_s
     when "src"
       css_symbol = "[src]"
       css = css_symbol.to_s
     when "href"
       css_symbol = "[href]"
       css = css_symbol.to_s
     when "alt"
       css_symbol = "[alt]"
       css = css_symbol.to_s
     else
       css_symbol = element[:attribute]
       css = css_symbol.to_s
     end
     css
   end

   def are_all_elements(code, tag, css_string)
     element_count = @elements.select{|hash| hash[:tag] == tag && !hash[:attribute]}.count
      code_count = code.css(css_string).count
      element_count > code_count ? false:true
   end

   def count_elements(code)
     uniq_elements =  @elements.group_by{|h| h[:tag]}
     uniq_elements.each do |e|
       if e[0] != "text"
        #  "element " + e[0].to_s
         element_count = e[1].select{|hash| !hash[:attribute]}.count
         if e[0] != "comment"
           code_count = code.css(e[0]).count
         else
           code_count = code.css("//comment()").count
         end

         if element_count > code_count
            @html_errors << new_error(element: e[0], type: 404, description:  "Remember to add the `<#{e[0]}>` tag.")
         end
      end
     end
   end

  #  def search_comments(code)
  #    comment_elements = code.css('//comment()')
   #
  #  end

   def search_attribute_value(code)
     uniq_elements =  @elements.group_by{|h| h[:tag]}
     uniq_elements.each do |e|

      element_with_attributes = e[1].select{|hash| hash[:attribute]}
      element_with_attributes.each do |ewa|

          css_string = build_css(ewa, '')

          if code.css(css_string).empty?
            @html_errors << new_error(element: ewa, type: 334, description: "`<#{ewa[:tag]}>` should have an attribute named #{ewa[:attribute]}")
          else

            if ewa[:value] != "" && code.css(css_string).select{|x| x[ewa[:attribute]].to_s == ewa[:value].to_s}.empty?
              @html_errors << new_error(element: ewa, type: 333, description: "Make sure that the attribute #{ewa[:attribute]} in `<#{ewa[:tag]}>` has the value #{ewa[:value]}")
            end

            if code.css(css_string).select{|x| x[ewa[:attribute]].to_s == ""}.any?
              @html_errors << new_error(element: ewa, type: 335, description: "`<#{ewa[:attribute]}>` in `<#{ewa[:tag]}>` can't be empty")
            end

          end

      end

    end


   end

   def add_children(parent)
     parent.children.each do |child|
       if child.attribute_nodes.empty?
          node = Hash.new
          node[:parent] = parent.name
          if child.name == "#cdata-section"
            node[:tag] = "text"
          else
            node[:tag] = child.name
          end
          node[:content] = child.text.strip if child.text and child.class != Nokogiri::XML::Element
          node[:pointer] = child.pointer_id
          node[:parent_pointer] = child.parent.pointer_id
          @elements << node
       else
         child.attribute_nodes.each do |element_attribute|
           node = Hash.new
           node[:parent] = parent.name
           if element_attribute.name == "#cdata-section"
             node[:tag] = "text"
           else
             node[:tag] = child.name
           end
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


end
