require 'test_helper'
require 'Nokogiri'


class CodeTerminatorWebDevelopmentTest < Minitest::Test

  # lesson 1
  # step 1

  def test_w_d_lesson_1_1
    ct = CodeTerminator::Html.new
    p errors = ct.match("exercises/web_development/lesson1_1.html","<p></p>")
    assert_equal errors.empty? , true
  end

  def test_w_d_lesson_1_1_with_text
    ct = CodeTerminator::Html.new
    p errors = ct.match("exercises/web_development/lesson1_1.html","<p>My test</p>")
    assert_equal errors.empty? , true
  end

  def test_w_d_lesson_1_1_empty_file
    ct = CodeTerminator::Html.new
    p errors = ct.match("exercises/web_development/lesson1_1.html","")
    assert_equal errors.empty? , false
  end

  def test_w_d_lesson_1_1_dif_element
    ct = CodeTerminator::Html.new
    p errors = ct.match("exercises/web_development/lesson1_1.html","<h1></h1>")
    assert_equal errors.empty? , false
  end

  # step 2

  def test_w_d_lesson_1_2
    ct = CodeTerminator::Html.new
    p errors = ct.match("exercises/web_development/lesson1_2.html","<!DOCTYPE html><html><head></head><body><p></p></body></html>")
    assert_equal errors.empty? , true
  end

  def test_w_d_lesson_1_2_with_text
    ct = CodeTerminator::Html.new
    p errors = ct.match("exercises/web_development/lesson1_2.html","<!DOCTYPE html><html><head>Hello</head><body><p>WD tests</p></body></html>")
    assert_equal errors.empty? , true
  end

  def test_w_d_lesson_1_2_empty_file
    ct = CodeTerminator::Html.new
    p errors = ct.match("exercises/web_development/lesson1_2.html","")
    assert_equal errors.empty? , false
  end

  def test_w_d_lesson_1_2_no_p
    ct = CodeTerminator::Html.new
    p errors = ct.match("exercises/web_development/lesson1_2.html","<!DOCTYPE html><html><head></head><body></body></html>")
    assert_equal errors.empty? , false
  end

  def test_w_d_lesson_1_2_no_head
    ct = CodeTerminator::Html.new
    p errors = ct.match("exercises/web_development/lesson1_2.html","<!DOCTYPE html><html><body><p></p></body></html>")
    assert_equal errors.empty? , false
  end

  def test_w_d_lesson_1_2_no_body
    ct = CodeTerminator::Html.new
    p errors = ct.match("exercises/web_development/lesson1_2.html","<!DOCTYPE html><html><head></head><p></p></html>")
    assert_equal errors.empty? , false
  end

  def test_w_d_lesson_1_2_no_html
    ct = CodeTerminator::Html.new
    p errors = ct.match("exercises/web_development/lesson1_2.html","<!DOCTYPE html><head></head><body><p></p></body>")
    assert_equal errors.empty? , false
  end

  # step 3

  def test_w_d_lesson_1_3
    ct = CodeTerminator::Html.new
    p errors = ct.match("exercises/web_development/lesson1_3.html","<!DOCTYPE html><html><head></head><body><!--This paragraph is Han speaking-->
<p>I love to fly my spaceship. My best friend is big and furry. Sometimes I get myself into sticky situations.</p><!--This paragraph is Chewbacca speaking-->
<p>Han is my best friend and he is the only one that understands me when I talk.</p></body></html>")
    assert_equal errors.empty? , true
  end

  def test_w_d_lesson_1_3_without_text
    ct = CodeTerminator::Html.new
    p errors = ct.match("exercises/web_development/lesson1_3.html","<!DOCTYPE html><html><head>Hello</head><body><!--This paragraph is Han speaking--><p></p><!--This paragraph is Chewbacca speaking--><p></p></body></html>")
    assert_equal errors.empty? , false
  end

  def test_w_d_lesson_1_3_dif_text
    ct = CodeTerminator::Html.new
    p errors = ct.match("exercises/web_development/lesson1_3.html","<!DOCTYPE html><html><head></head><body><!--This paragraph is Han speaking-->
<p>I love to fly my spaceship.</p><!--This paragraph is Chewbacca speaking-->
<p>Han is my best friend and he is the only one.</p></body></html>")
    assert_equal errors.empty? , false
  end

  def test_w_d_lesson_1_3_without_comment
    ct = CodeTerminator::Html.new
    p errors = ct.match("exercises/web_development/lesson1_3.html","<!DOCTYPE html><html><head>Hello</head><body><p>I love to fly my spaceship. My best friend is big and furry. Sometimes I get myself into sticky situations.</p><p>Han is my best friend and he is the only one that understands me when I talk.</p></body></html>")
    assert_equal errors.empty? , false
  end

  def test_w_d_lesson_1_3_with_dif_comment
    ct = CodeTerminator::Html.new
    p errors = ct.match("exercises/web_development/lesson1_3.html","<!DOCTYPE html><html><head>Hello</head><body><!--This --><p>I love to fly my spaceship. My best friend is big and furry. Sometimes I get myself into sticky situations.</p><!--This paragraph --><p>Han is my best friend and he is the only one that understands me when I talk.</p></body></html>")
    assert_equal errors.empty? , false
  end

  def test_w_d_lesson_1_3_empty_file
    ct = CodeTerminator::Html.new
    p errors = ct.match("exercises/web_development/lesson1_3.html","")
    assert_equal errors.empty? , false
  end

  def test_w_d_lesson_1_3_no_p
    ct = CodeTerminator::Html.new
    p errors = ct.match("exercises/web_development/lesson1_3.html","<!DOCTYPE html><html><head></head><body></body></html>")
    assert_equal errors.empty? , false
  end

  def test_w_d_lesson_1_3_no_head
    ct = CodeTerminator::Html.new
    p errors = ct.match("exercises/web_development/lesson1_3.html","<!DOCTYPE html><html><body><p>I love to fly my spaceship. My best friend is big and furry. Sometimes I get myself into sticky situations.</p><p>Han is my best friend and he is the only one that understands me when I talk.</p></body></html>")
    assert_equal errors.empty? , false
  end

  def test_w_d_lesson_1_3_no_body
    ct = CodeTerminator::Html.new
    p errors = ct.match("exercises/web_development/lesson1_3.html","<!DOCTYPE html><html><head></head><p>I love to fly my spaceship. My best friend is big and furry. Sometimes I get myself into sticky situations.</p><p>Han is my best friend and he is the only one that understands me when I talk.</p></html>")
    assert_equal errors.empty? , false
  end

  def test_w_d_lesson_1_3_no_html
    ct = CodeTerminator::Html.new
    p errors = ct.match("exercises/web_development/lesson1_3.html","<!DOCTYPE html><head></head><body><p>I love to fly my spaceship. My best friend is big and furry. Sometimes I get myself into sticky situations.</p><p>Han is my best friend and he is the only one that understands me when I talk.</p></body>")
    assert_equal errors.empty? , false
  end

end
