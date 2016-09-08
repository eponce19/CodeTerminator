require 'Jshint'

class CodeTerminator::Js

  def initialize(args = {})
    @code = args[:code]
    @source = args[:source]
    @tags = Array.new
  end

     # Validate if the syntax is correct. If is valid return boolean true.
     #
     # Example:
     #   >> CodeTerminator::Html.validate_syntax("app/exercises/js/calculator.js")
     #   => true
     #
     # Arguments:
     #   source: (String)
     #

  def validate_syntax(source)
    j = Jshint::Lint.new
    j.config.options["files"] = source
    p j.lint
    p j.errors
    p j.config
    p j
    j.errors
  end


end
