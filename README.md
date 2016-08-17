# CodeTerminator

CodeTerminator is a gem that helps to <strike>exterminate Sarah Connor</strike> parse, evaluate and compare html code. Also is useful when you need to check html code syntaxis.

##Features
<ul>
<li>HTML parser </li>
<li>CSS parser (Coming soon)</li>
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

To parse HTML and match the file with html code you just need to do:
```ruby
    # code = code get from an editor
    # source = Source of the file you want to compare with
    
    # First, validate syntasis of the code
    ct = CodeTerminator::Html.new
    errors = ct.validate_syntax(code)
    result << errors[0]
    
    # If code do't have errors, match the code with your html file
    if errors.empty?
      result = ct.match(source, code)
    end
```
If the code and the source mismatch,  `ct.match()`  will return an array with the differences between code and source file.
You will know that the code and the source file have the same html elements when the `ct.match()` return a nil array.

```ruby
	# hola_mundo.html
	# 	<h1>Hola Mundo!</h1>
	#
    >> CodeTerminator::Html.match("hola_mundo.html","<h2>Hola Mundo!</h2>")
    #   => ["h1 not exist"]
```

##Cheat Sheet

###match(source, code)
Match if the code have the same elements than the exercise. Return an array with the mismatches.

```ruby
   #   hola_mundo.html
   # => <h1>Hola Mundo!</h1>
```
```ruby
   CodeTerminator::Html.match("hola_mundo.html","<h2>Hola Mundo!</h2>")
   #   => ["h1 not exist"]
   #
```
###new_file(source, code)
Create a Html file with the code of the editor. Return a boolean that indicate if the file was created or not.
```ruby
    CodeTerminator::Html.new_file("hola_mundo.html", "<h1>Hola Mundo!</h1>")
    #   => true
```
###read_file(source)
Read a html file. Return the text of the file.
```ruby
    CodeTerminator::Html.read_file("hola_mundo.html")
     #   => "<h1>Hola Mundo!</h1>"
```

###validate_syntax(code)
Validate if the syntax is correct. Return an array with Nokogiri errors.
```ruby
   CodeTerminator::Html.validate_syntax("<h1>Hola Mundo!</h1")
     #   => [#<Nokogiri::XML::SyntaxError: expected '>'>]
```
  
###get_elements(source)
Get html elements of a html file. Return a list of Nokogiri XML objects.
```ruby
    CodeTerminator::Html.get_elements("hola_mundo.html")
     #   => [#<Nokogiri::XML::Element:0x3fe3391547d8 name="h1" children=[#<Nokogiri::XML::Text:0x3fe33915474c "Hola Mundo!">]>, #<Nokogiri::XML::Text:0x3fe33915474c "Hola Mundo!">]
```

###print_elements(Elements Array)
Get the elements of the code in html format. Return a string with elements in html.
<br>
**Get 'Elements Array' calling 'get_elements()'
```ruby
     CodeTerminator::Html.print_elements([#<Nokogiri::XML::Element:0x3fe31dc42bfc name="h1" children=[#<Nokogiri::XML::Text:0x3fe31dc42b70 "hola mundo">]>, #<Nokogiri::XML::Text:0x3fe31dc42b70 "hola mundo">])
     #   => "name = h1<br><hr>name = text<br>content = hola mundo<br><hr>"
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

