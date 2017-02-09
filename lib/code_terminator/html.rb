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


end
