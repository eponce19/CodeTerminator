# CodeTerminator

CodeTerminator is a gem that helps to <strike>exterminate Sarah Connor</strike> parse, evaluate and compare html and css code. Also is useful when you need to check html and css code syntaxis.

##Features
<ul>
<li>HTML parser </li>
<li>CSS parser </li>
</ul>

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'code_terminator'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install code_terminator

## Quick Start

#####HTML
To parse HTML and match the file with html code you just need to do:
```ruby
    # code = code get from an editor
    # source = Source of the file you want to compare with

    # First, validate syntasis of the code
    ct = CodeTerminator::Html.new
    errors = ct.validate_syntax(code)
    result << errors[0]

    # If code don't have errors, match the code with your html file
    if errors.empty?
      result = ct.match(source, code)
    end
```
If the code and the source mismatch,  `ct.match()`  will return an array with the differences between code and source file.
You will know that the code and the source file have the same html elements when the `ct.match()` return a nil array.

```ruby
	# hola_mundo.html
	# 	<h1>Come with me if you want to live!</h1>
	#
    >> ct.match("hola_mundo.html","<h2>Come with me if you want to live!</h2>")
    #   => ["h1 not exist"]
```

##### CSS
To parse CSS and match the file with css code you just need to do:
```ruby
    # code = code get from an editor
    # source = Source of the file you want to compare with

    # First, validate syntasis of the code
    ct = CodeTerminator::Css.new
    errors = ct.validate_syntax(code)

    # If code do't have errors, match the code with your html file
    if errors.empty?
      result = ct.match(source, code)
    end
```
If the code and the source mismatch,  `ct.match()`  will return an array with the differences between code and source file.
You will know that the code and the source file have the same css elements when the `ct.match()` return a nil array.

```ruby
	# test.css
	# => h1{ margin: 100px; }
	#
    >> ct.match("test.html","h1{ margin: 50px; }")
    #   => ["not the same property margin: 100px in selector h1"]
```

##Cheat Sheet

###match(source, code)
Match if the code have the same elements than the exercise. Return an array with the mismatches.

####HTML
```ruby
   #   hola_mundo.html
   # => <h1>Come with me if you want to live!</h1>
```
```ruby
   >> ct = CodeTerminator::Html.new
   >> ct.match("hola_mundo.html","<h2>Come with me if you want to live!</h2>")
   #   => ["h1 not exist"]
   #
```

#####CSS
```ruby
   #   test.css
   # => h1{ margin: 100px; }
```
```ruby
   >> ct = CodeTerminator::Css.new
   >> ct.match("hola_mundo.css","h1{ margin: 50px; }")
   #   => ["not the same property margin: 100px in selector h1"]
   #
```

###new_file(source, code)
Create a Html/Css file with the code of the editor. Return a boolean that indicate if the file was created or not.
#####HTML
```ruby
    >> ct = CodeTerminator::Html.new
    >> ct.new_file("hola_mundo.html", "<h1>Come with me if you want to live!</h1>")
    #   => true
```
#####CSS
```ruby
    >> ct = CodeTerminator::Css.new
    >> ct.new_file("hola_mundo.css", "h1{ margin: 50px; }")
    #   => true
```

###read_file(source)
Read a html file. Return the text of the file.
#####HTML
```ruby
    >> ct = CodeTerminator::Html.new
    >> ct.read_file("hola_mundo.html")
     #   => "<h1>Come with me if you want to live!</h1>"
```
#####CSS
```ruby
    >> ct = CodeTerminator::Css.new
    >> ct.read_file("hola_mundo.css")
     #   => "h1{ margin: 50px; }"
```

###validate_syntax(code)
Validate if the syntax is correct. Return an array with errors.
#####HTML
```ruby
    >> ct = CodeTerminator::Html.new
    >> ct.validate_syntax("<h1>Come with me if you want to live!</h1")
     #   => [#<Nokogiri::XML::SyntaxError: expected '>'>]
```
#####CSS
```ruby
    >> ct = CodeTerminator::Css.new
    >> ct.validate_syntax("h1{ margi")
     #   => ["error"]
```

###get_elements(source)
Get html elements of a html file. Return a list of elements with their properties.
#####HTML
```ruby
    >> ct = CodeTerminator::Html.new
    >> ct.get_elements("hola_mundo.html")
     #   => [{:parent=>"body", :tag=>"div", :attribute=>"class", :value=>"col-md-12"}, {:parent=>"div", :tag=>"h1"}, {:parent=>"h1", :tag=>"text", :content=>"Come with me if you want to live!"}]
```
#####CSS
```ruby
    >> ct = CodeTerminator::Css.new
    >> ct.get_elements("hola_mundo.css")
     #   => [{:selector=>"h1"}, {:selector=>"h1", :property=>"margin", :value=>"50px"}]
```

###get_instructions(source)
Get the instructions to recreate the html code. Return an array with strings .
#####HTML
```ruby
    >> ct = CodeTerminator::Html.new
    >> ct.get_instructions("hola_mundo.html")
     #   => ["Add the tag h2 in body", " In h2 add the text 'hola test' ", "Add the tag p in body"]
```
#####CSS
```ruby
    >> ct = CodeTerminator::Css.new
    >> ct.get_instructions("hola_mundo.css")
     #   => ["Create the selector body", "In the selector body add the property ' background-color'  with value 'yellow' "]
```

###print_elements(source)
Get the elements of the code in html format. Return a string with elements in html.
<br>
#####HTML
```ruby
     CodeTerminator::Html.print_elements("exercises/hola_mundo.html" )
     #   => "name = h1<br><hr>name = text<br>content = Come with me if you want to live!<br><hr>"
     #
```
#####CSS
```ruby
     CodeTerminator::Css.print_elements("exercises/hola_mundo.css" )
     #   => "selector = h1<br><hr>property = margin<br>value = 50px<br><hr>"
     #
```

##Example
An example of an editor using CodeTerminator is available at https://github.com/eponce19/editor_terminator.git


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment. Run `bundle exec code_terminator` to use the gem in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/eponce19/code_terminator. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
