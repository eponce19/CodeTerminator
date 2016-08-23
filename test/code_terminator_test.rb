require 'test_helper'

class CodeTerminatorTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::CodeTerminator::VERSION
  end

  def test_html_create_new_file
      ct = CodeTerminator::Html.new
      assert_equal ct.new_file("exercises/test.html","<h2>hola test</h2>") , true
  end

  def test_html_read_file
      ct = CodeTerminator::Html.new
      assert_equal ct.read_file("exercises/test.html") != false , true
  end

  def test_html_get_elements
      ct = CodeTerminator::Html.new
      assert_equal ct.get_elements("exercises/test.html").any? , true
  end

  def test_html_validate_correct_syntax
      ct = CodeTerminator::Html.new
      assert_equal ct.validate_syntax("<h2>hola test</h2>").empty? , true
  end

  def test_html_validate_wrong_syntax
      ct = CodeTerminator::Html.new
      assert_equal ct.validate_syntax("<h2>hola test</h2").any? , true
  end

  def test_html_print_elements
      ct = CodeTerminator::Html.new
      elements = ct.get_elements("exercises/test.html")
      test_text = "name = h2<br><hr>name = text<br>content = hola test<br><hr>"
      assert_equal ct.print_elements(elements) == test_text , true
  end

  def test_html_match
      ct = CodeTerminator::Html.new
      html_errors = ct.match("exercises/test.html","<h2>hola test</h2>")
      assert_equal html_errors.empty? , true
  end

  def test_html_mismatch
      ct = CodeTerminator::Html.new
      html_errors = ct.match("exercises/test.html","<h1>hola test</h1>")
      assert_equal html_errors.empty? , false
  end




  def test_css_create_new_file
      ct = CodeTerminator::Css.new
      assert_equal ct.new_file("exercises/test.css","body {
    background-color: lightblue; }") , true
  end

  def test_css_read_file
      ct = CodeTerminator::Css.new
      assert_equal ct.read_file("exercises/test.css") != false , true
  end

  def test_css_get_elements
      ct = CodeTerminator::Css.new
      p ct.get_elements("exercises/test.css")
      assert_equal ct.get_elements("exercises/test.css").any? , true
  end

  def test_css_validate_correct_syntax
      ct = CodeTerminator::Css.new
      assert_equal ct.validate_syntax("body { background-color: lightblue; }") , true
  end

  def test_css_validate_wrong_syntax
      ct = CodeTerminator::Css.new
      assert_equal ct.validate_syntax("body { background-colo") , false
  end

  def test_css_print_elements
      ct = CodeTerminator::Css.new
      elements = ct.get_elements("exercises/test.css")
      p ct.print_elements(elements)
      test_text = "selector = body<br><hr>selector = body<br>property = background-color<br>value = lightblue<br><hr>"
      assert_equal ct.print_elements(elements) == test_text , true
  end

  def test_css_match
      ct = CodeTerminator::Css.new
      css_errors = ct.match("exercises/test.css","body {
    background-color: lightblue; }")
      p css_errors
      assert_equal css_errors.empty? , true
  end

  def test_css_mismatch
      ct = CodeTerminator::Css.new
      css_errors = ct.match("exercises/test.css","body {
    background-color: blue; }")
      p css_errors
      assert_equal css_errors.empty? , false
  end

end
