require 'test_helper'
require 'Nokogiri'


class CodeTerminatorWebDevelopmentTest < Minitest::Test

  # lesson 1
  # step 1

  def test_w_d_lesson_1_1
    ct = CodeTerminator::Html.new
    errors = ct.match("exercises/web_development/lesson1_1.html","<p></p>")
    assert_equal errors.empty? , true
  end

  def test_w_d_lesson_1_1_with_text
    ct = CodeTerminator::Html.new
    errors = ct.match("exercises/web_development/lesson1_1.html","<p>My test</p>")
    assert_equal errors.empty? , true
  end

  def test_w_d_lesson_1_1_empty_file
    ct = CodeTerminator::Html.new
    errors = ct.match("exercises/web_development/lesson1_1.html","")
    assert_equal errors.empty? , false
  end

  def test_w_d_lesson_1_1_dif_element
    ct = CodeTerminator::Html.new
    errors = ct.match("exercises/web_development/lesson1_1.html","<h1></h1>")
    assert_equal errors.empty? , false
  end

  # step 2

  def test_w_d_lesson_1_2
    ct = CodeTerminator::Html.new
    errors = ct.match("exercises/web_development/lesson1_2.html","<!DOCTYPE html><html><head></head><body><p></p></body></html>")
    assert_equal errors.empty? , true
  end

  def test_w_d_lesson_1_2_with_text
    ct = CodeTerminator::Html.new
    errors = ct.match("exercises/web_development/lesson1_2.html","<!DOCTYPE html><html><head>Hello</head><body><p>WD tests</p></body></html>")
    assert_equal errors.empty? , true
  end

  def test_w_d_lesson_1_2_empty_file
    ct = CodeTerminator::Html.new
    errors = ct.match("exercises/web_development/lesson1_2.html","")
    assert_equal errors.empty? , false
  end

  def test_w_d_lesson_1_2_no_p
    ct = CodeTerminator::Html.new
    errors = ct.match("exercises/web_development/lesson1_2.html","<!DOCTYPE html><html><head></head><body></body></html>")
    assert_equal errors.empty? , false
  end

  def test_w_d_lesson_1_2_no_head
    ct = CodeTerminator::Html.new
    errors = ct.match("exercises/web_development/lesson1_2.html","<!DOCTYPE html><html><body><p></p></body></html>")
    assert_equal errors.empty? , false
  end


  # step 3

  def test_w_d_lesson_1_3
    ct = CodeTerminator::Html.new
    p errors = ct.match("exercises/web_development/lesson1_3.html","<!DOCTYPE html><html><head></head><body><!-- This paragraph is Han speaking --><p>I love to fly my spaceship. My best friend is big and furry. Sometimes I get myself into sticky situations.</p><!--This paragraph is Chewbacca speaking--><p>Han is my best friend and he is the only one that understands me when I talk.</p></body></html>")
    assert_equal errors.empty? , true
  end

  def test_w_d_lesson_1_3_without_text
    ct = CodeTerminator::Html.new
    errors = ct.match("exercises/web_development/lesson1_3.html","<!DOCTYPE html><html><head></head><body><!--This paragraph is Han speaking--><p></p><!--This paragraph is Chewbacca speaking--><p></p></body></html>")
    assert_equal errors.empty? , false
  end

  def test_w_d_lesson_1_3_dif_text
    ct = CodeTerminator::Html.new
    errors = ct.match("exercises/web_development/lesson1_3.html","<!DOCTYPE html><html><head></head><body><!--This paragraph is Han speaking-->
<p>I love to fly my spaceship.</p><!--This paragraph is Chewbacca speaking-->
<p>Han is my best friend and he is the only one.</p></body></html>")
    assert_equal errors.empty? , false
  end

  def test_w_d_lesson_1_3_without_comment
    ct = CodeTerminator::Html.new
    errors = ct.match("exercises/web_development/lesson1_3.html","<!DOCTYPE html><html><head></head><body><p>I love to fly my spaceship. My best friend is big and furry. Sometimes I get myself into sticky situations.</p><p>Han is my best friend and he is the only one that understands me when I talk.</p></body></html>")
    assert_equal errors.empty? , false
  end

  def test_w_d_lesson_1_3_with_dif_comment
    ct = CodeTerminator::Html.new
    errors = ct.match("exercises/web_development/lesson1_3.html","<!DOCTYPE html><html><head></head><body><!--This --><p>I love to fly my spaceship. My best friend is big and furry. Sometimes I get myself into sticky situations.</p><!--This paragraph --><p>Han is my best friend and he is the only one that understands me when I talk.</p></body></html>")
    assert_equal errors.empty? , false
  end

  def test_w_d_lesson_1_3_empty_file
    ct = CodeTerminator::Html.new
    errors = ct.match("exercises/web_development/lesson1_3.html","")
    assert_equal errors.empty? , false
  end

  def test_w_d_lesson_1_3_no_p
    ct = CodeTerminator::Html.new
    errors = ct.match("exercises/web_development/lesson1_3.html","<!DOCTYPE html><html><head></head><body></body></html>")
    assert_equal errors.empty? , false
  end

  def test_w_d_lesson_1_3_no_head
    ct = CodeTerminator::Html.new
    errors = ct.match("exercises/web_development/lesson1_3.html","<!DOCTYPE html><html><body><p>I love to fly my spaceship. My best friend is big and furry. Sometimes I get myself into sticky situations.</p><p>Han is my best friend and he is the only one that understands me when I talk.</p></body></html>")
    assert_equal errors.empty? , false
  end


  # step 4

  def test_w_d_lesson_1_4
    ct = CodeTerminator::Html.new
    p errors = ct.match("exercises/web_development/lesson1_4.html","<!DOCTYPE html><html><head><title></title></head><body><h1></h1><p></p></body></html>")
    assert_equal errors.empty? , true
  end

  def test_w_d_lesson_1_4_empty_file
    ct = CodeTerminator::Html.new
    errors = ct.match("exercises/web_development/lesson1_4.html","")
    assert_equal errors.empty? , false
  end

  def test_w_d_lesson_1_4_no_h1
    ct = CodeTerminator::Html.new
    errors = ct.match("exercises/web_development/lesson1_4.html","<!DOCTYPE html><html><head><title></title></head><body><p></p></body></html>")
    assert_equal errors.empty? , false
  end

  def test_w_d_lesson_1_4_no_p
    ct = CodeTerminator::Html.new
    errors = ct.match("exercises/web_development/lesson1_4.html","<!DOCTYPE html><html><head><title></title></head><body><h1></h1></body></html>")
    assert_equal errors.empty? , false
  end

  def test_w_d_lesson_1_4_no_head
    ct = CodeTerminator::Html.new
    errors = ct.match("exercises/web_development/lesson1_4.html","<!DOCTYPE html><html><body><h1></h1></body></html>")
    assert_equal errors.empty? , false
  end

  def test_w_d_lesson_1_4_no_title
    ct = CodeTerminator::Html.new
    p "errores"
    p errors = ct.match("exercises/web_development/lesson1_4.html","<!DOCTYPE html><html><head></head><body><h1></h1></body></html>")
    assert_equal errors.empty? , false
  end

  # step 5

  def test_w_d_lesson_1_5
    ct = CodeTerminator::Html.new
    p errors = ct.match("exercises/web_development/lesson1_5.html","<!DOCTYPE html><html><head><title></title></head><body><img src='hola'><img src='hello'><img src='hi'></body></html>")
    assert_equal errors.empty? , true
  end

  def test_w_d_lesson_1_5_empty_src
    ct = CodeTerminator::Html.new
    p errors = ct.match("exercises/web_development/lesson1_5.html","<!DOCTYPE html><html><head><title></title></head><body><img src=''><img src=''><img src=''></body></html>")
    assert_equal errors.empty? , false
  end

  def test_w_d_lesson_1_5_empty_file
    ct = CodeTerminator::Html.new
    errors = ct.match("exercises/web_development/lesson1_5.html","")
    assert_equal errors.empty? , false
  end

  def test_w_d_lesson_1_4_no_imgs
    ct = CodeTerminator::Html.new
    errors = ct.match("exercises/web_development/lesson1_4.html","<!DOCTYPE html><html><head><title></title></head><body></body></html>")
    assert_equal errors.empty? , false
  end

  def test_w_d_lesson_1_4_no_one_img
    ct = CodeTerminator::Html.new
    errors = ct.match("exercises/web_development/lesson1_4.html","<!DOCTYPE html><html><head><title></title></head><body><img src='hi'><img src='hola'></body></html>")
    assert_equal errors.empty? , false
  end

  #step 6

  def test_w_d_lesson_1_6
    ct = CodeTerminator::Html.new
    p errors = ct.match("exercises/web_development/lesson1_6.html","<!DOCTYPE html><html><head><title></title></head><body><ul><li></li></ul></body></html>")
    assert_equal errors.empty? , true
  end

  def test_w_d_lesson_1_6_no_ul
    ct = CodeTerminator::Html.new
    p errors = ct.match("exercises/web_development/lesson1_6.html","<!DOCTYPE html><html><head><title></title></head><body></body></html>")
    assert_equal errors.empty? , false
  end

  def test_w_d_lesson_1_6_no_li
    ct = CodeTerminator::Html.new
    p errors = ct.match("exercises/web_development/lesson1_6.html","<!DOCTYPE html><html><head><title></title></head><body><ul></ul></body></html>")
    assert_equal errors.empty? , false
  end

  def test_w_d_lesson_1_6_empty_file
    ct = CodeTerminator::Html.new
    errors = ct.match("exercises/web_development/lesson1_6.html","")
    assert_equal errors.empty? , false
  end

  #step 7

  def test_w_d_lesson_1_7
    ct = CodeTerminator::Html.new
    p errors = ct.match("exercises/web_development/lesson1_7.html","<!DOCTYPE html><html><head><title></title></head><body><a href='cat'></a><a href='dog'></a><a href='fish'></a><a href='lion'></a><a href='tiger'></a></body></html>")
    assert_equal errors.empty? , true
  end

  def test_w_d_lesson_1_7_no_a
    ct = CodeTerminator::Html.new
    p errors = ct.match("exercises/web_development/lesson1_7.html","<!DOCTYPE html><html><head><title></title></head><body></body></html>")
    assert_equal errors.empty? , false
  end

  def test_w_d_lesson_1_7_no_href
    ct = CodeTerminator::Html.new
    p errors = ct.match("exercises/web_development/lesson1_7.html","<!DOCTYPE html><html><head><title></title></head><body><a href=''></a><a href=''></a><a href=''></a><a href=''></a><a href=''></a></body></html>")
    assert_equal errors.empty? , false
  end

  def test_w_d_lesson_1_7_no_text_href
    ct = CodeTerminator::Html.new
    p errors = ct.match("exercises/web_development/lesson1_7.html","<!DOCTYPE html><html><head><title></title></head><body><a></a><a></a><a></a><a></a><a></a></body></html>")
    assert_equal errors.empty? , false
  end

  def test_w_d_lesson_1_7_no_one_img
    ct = CodeTerminator::Html.new
    errors = ct.match("exercises/web_development/lesson1_7.html","<!DOCTYPE html><html><head><title></title></head><body><a href='cat'></a><a href='dog'></a><a href='fish'></a><a href='lion'></a></body></html>")
    assert_equal errors.empty? , false
  end

  def test_w_d_lesson_1_7_empty_file
    ct = CodeTerminator::Html.new
    errors = ct.match("exercises/web_development/lesson1_7.html","")
    assert_equal errors.empty? , false
  end


  #lesson_1_challenge

  def test_w_d_lesson_1_challenge
    ct = CodeTerminator::Html.new
    p errors = ct.match("exercises/web_development/lesson1_challenge.html","<!DOCTYPE html><html><head><title></title></head><body><h1></h1><p></p><img src='some'><h1></h1><p></p><img src='text'><h1></h1><p></p><img src='text'><a href='some'></a><a href='text'></a><a href='some'></a><a href='text'></a><a href='text'></a></body></html>")
    assert_equal errors.empty? , true
  end

  def test_w_d_lesson_1_challenge_no_text
    ct = CodeTerminator::Html.new
    p errors = ct.match("exercises/web_development/lesson1_challenge.html","<!DOCTYPE html><html><head><title></title></head><body><h1></h1><p></p><img src=''><h1></h1><p></p><img src=''><h1></h1><p></p><img src=''><a href=''></a><a href=''></a><a href=''></a><a href=''></a><a href=''></a></body></html>")
    assert_equal errors.empty? , false
  end

  def test_w_d_lesson_1_challenge_empty
    ct = CodeTerminator::Html.new
    p errors = ct.match("exercises/web_development/lesson1_7.html","<!DOCTYPE html><html><head><title></title></head><body></body></html>")
    assert_equal errors.empty? , false
  end


end
