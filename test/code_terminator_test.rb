require 'test_helper'
require 'Nokogiri'


class CodeTerminatorTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::CodeTerminator::VERSION
  end

  # def test_html_create_new_file
  #     ct = CodeTerminator::Html.new
  #     assert_equal ct.new_file("exercises/new_file.html","<body><h2>hola test</h2><p></p></body>") , true
  # end
  #
  # def test_html_read_file
  #     ct = CodeTerminator::Html.new
  #     assert_equal ct.read_file("exercises/read_file.html") != false , true
  # end
  #
  # def test_html_get_elements
  #     ct = CodeTerminator::Html.new
  #     elements = ct.get_elements("exercises/test.html")
  #     assert_equal elements.any? , true
  # end
  #
  # def test_html_print_elements
  #     ct = CodeTerminator::Html.new
  #     elements = ct.get_elements("exercises/print_elements.html")
  #     assert_equal elements.empty? , false
  # end
  #
  # def test_html_check_comment_exist
  #   ct = CodeTerminator::Html.new
  #   p "1 test if comment exist in code with comment"
  #   p errors = ct.match("exercises/html/check_comment_exist.html","<html><head></head><body><!-- This is a comment --></body></html>")
  #   assert_equal errors.empty? , true
  # end
  #
  # def test_html_check_comment_exist_error
  #   ct = CodeTerminator::Html.new
  #   p "2 test if comment with text exist in code without comment, throw an error"
  #   p errors = ct.match("exercises/html/check_comment_exist.html","<html><head></head><body></body></html>")
  #   assert_equal errors.empty? , false
  # end
  #
  # def test_html_check_comment_text
  #   ct = CodeTerminator::Html.new
  #   p "3 test if text in comment is the same as the text of comment in code"
  #   p errors = ct.match("exercises/html/check_comment_text.html","<html><head></head><body><!-- This is a comment --></body></html>")
  #   assert_equal errors.empty? , true
  # end
  #
  # def test_html_check_comment_text_error
  #   ct = CodeTerminator::Html.new
  #   p "4 test if text in comment is the same as the text of comment in code"
  #   p errors = ct.match("exercises/html/check_comment_text.html","<html><head></head><body><!-- This is a string --></body></html>")
  #   assert_equal errors.empty? , false
  # end
  #
  # def test_html_check_comment_empty
  #   ct = CodeTerminator::Html.new
  #   p "5 test if text in comment of the code can be different in empty comments"
  #   p errors = ct.match("exercises/html/check_comment_empty.html","<html><head></head><body><!-- This is MY comment --></body></html>")
  #   assert_equal errors.empty? , true
  # end
  #
  # def test_html_check_comment_empty_error
  #   ct = CodeTerminator::Html.new
  #   p "6 test if empty comment dont exist throw an error"
  #   p errors = ct.match("exercises/html/check_comment_empty.html","<html><head></head><body></body></html>")
  #   assert_equal errors.empty? , false
  # end
  #
  # def test_html_check_text_empty_children
  #   ct = CodeTerminator::Html.new
  #   p "7 test if text in empty children can be different in code"
  #   p errors = ct.match("exercises/html/check_text_empty_children.html","<html><head></head><body>This is text in body<h1>This is text in children</h1></body></html>")
  #   assert_equal errors.empty? , true
  # end
  #
  # def test_html_check_text_empty_parent
  #   ct = CodeTerminator::Html.new
  #   p "8 test if text in empty parent can be different in code"
  #   p errors = ct.match("exercises/html/check_text_empty_children.html","<html><head></head><body>This is text in body<h1>This is text in child</h1></body></html>")
  #   assert_equal errors.empty? , true
  # end
  #
  # def test_html_check_text_exists_children
  #   ct = CodeTerminator::Html.new
  #   p "9 test if text in children is the same in code"
  #   p errors = ct.match("exercises/html/check_text_exists_children.html","<html><head></head><body>This is text in body<h1>This is text in child</h1></body></html>")
  #   assert_equal errors.empty? , true
  # end
  #
  # def test_html_check_text_exists_children_error
  #   ct = CodeTerminator::Html.new
  #   p "10 test if text in children is different in code, throw error"
  #   p errors = ct.match("exercises/html/check_text_exists_children.html","<html><head></head><body>This is text in body<h1>This is a title</h1></body></html>")
  #   assert_equal errors.empty? , false
  # end
  #
  # def test_html_check_text_exists_parent
  #   ct = CodeTerminator::Html.new
  #   p "11 test if text in parent is the same in code"
  #   p errors = ct.match("exercises/html/check_text_exists_parent.html","<html><head></head><body>This is text in body<h1>This is text in child</h1></body></html>")
  #   assert_equal errors.empty? , true
  # end
  #
  # def test_html_check_text_exists_parent_error
  #   ct = CodeTerminator::Html.new
  #   p "12 test if text in parent is different in code, throw error"
  #   p errors = ct.match("exercises/html/check_text_exists_parent.html","<html><head></head><body>This is a title<h1>This is a text in child</h1></body></html>")
  #   assert_equal errors.empty? , false
  # end
  #
  # def test_html_check_text_empty_children
  #   ct = CodeTerminator::Html.new
  #   p "13 test if text in children can be different in code"
  #   p errors = ct.match("exercises/html/check_text_empty_children.html","<html><head></head><body>This is text in body<h1>This is MY text in child</h1></body></html>")
  #   assert_equal errors.empty? , true
  # end
  #
  # def test_html_check_text_empty_children_error
  #   ct = CodeTerminator::Html.new
  #   p "14 test if tag dont exist even the text is empty in children, throw error"
  #   p errors = ct.match("exercises/html/check_text_empty_children.html","<html><head></head><body>This is text in body</body></html>")
  #   assert_equal errors.empty? , false
  # end
  #
  # def test_html_check_text_empty_parent
  #   ct = CodeTerminator::Html.new
  #   p "15 test if text in parent can be different in code"
  #   p errors = ct.match("exercises/html/check_text_empty_parent.html","<html><head></head><body>This is MY text in body<h1>This is text in child</h1></body></html>")
  #   assert_equal errors.empty? , true
  # end
  #
  # def test_html_check_div_exist
  #   ct = CodeTerminator::Html.new
  #   p "16 test if div exists"
  #   p errors = ct.match("exercises/html/check_div_exist.html","<html><head></head><body><div><h1>2017</h1></div></body></html>")
  #   assert_equal errors.empty? , true
  # end
  #
  # def test_html_check_div_exist_error
  #   ct = CodeTerminator::Html.new
  #   p "17 test if div dont exists, throw error"
  #   p errors = ct.match("exercises/html/check_div_exist.html","<html><head></head><body></body></html>")
  #   assert_equal errors.empty? , false
  # end
  #
  # def test_html_check_div_empty
  #   ct = CodeTerminator::Html.new
  #   p "18 test if div exists can contain elements in code"
  #   p errors = ct.match("exercises/html/check_div_exist.html","<html><head></head><body><div><h1>2017</h1><h2>2018</h2></div></body></html>")
  #   assert_equal errors.empty? , true
  # end
  #
  # def test_html_check_div_children_exist
  #   ct = CodeTerminator::Html.new
  #   p "19 test if div contains the children in code"
  #   p errors = ct.match("exercises/html/check_div_children_exist.html","<html><head></head><body><div><h1>2017</h1><h2>2018</h2></div></body></html>")
  #   assert_equal errors.empty? , true
  # end
  #
  # def test_html_check_div_children_exist_error
  #   ct = CodeTerminator::Html.new
  #   p "20 test if div dont contains the children in code, throw error"
  #   p errors = ct.match("exercises/html/check_div_children_exist.html","<html><head></head><body><div></div></body></html>")
  #   assert_equal errors.empty? , false
  # end
  #
  # def test_html_check_get_children_in_parent_exist
  #   ct = CodeTerminator::Html.new
  #   p "A test if parent contains the children in code"
  #   p errors = ct.match("exercises/html/check_div_children_exist.html","<html><head></head><body><div><h1>2017</h1><h2>2018</h2></div></body></html>")
  #   assert_equal errors.empty? , true
  # end
  #
  # def test_html_check_get_empty_children_in_parent_exist_error
  #   ct = CodeTerminator::Html.new
  #   p "B test if parent dont contains the empty children in code, throw error"
  #   p errors = ct.match("exercises/html/check_get_empty_children_in_parent.html","<html><head></head><body><div></div></body></html>")
  #   assert_equal errors.empty? , false
  # end
  #
  # def test_html_check_get_children_in_parent_exist_error
  #   ct = CodeTerminator::Html.new
  #   p "C test if parent contains the children in code"
  #   p errors = ct.match("exercises/html/check_get_children_in_parent.html","<html><head></head><body><div></div></body></html>")
  #   assert_equal errors.empty? , false
  # end
  #
  # def test_html_check_div_same_empty_children_exist
  #   ct = CodeTerminator::Html.new
  #   p "21 test if div contains empty child with same tag"
  #   p errors = ct.match("exercises/html/check_div_same_empty_children_exist.html","<html><head></head><body><div><h1>2017</h1><h2>2018</h2><h2>2019</h2></div></body></html>")
  #   assert_equal errors.empty? , true
  # end
  #
  # def test_html_check_div_same_empty_children_exist_error
  #   ct = CodeTerminator::Html.new
  #   p "22 test if div dont contains empty child with same tag"
  #   p errors = ct.match("exercises/html/check_div_same_empty_children_exist.html","<html><head></head><body><div><h1>2017</h1><h2>2018</h2></div></body></html>")
  #   assert_equal errors.empty? , false
  # end
  #
  # def test_html_check_div_same_children_exist
  #   ct = CodeTerminator::Html.new
  #   p "23 test if div contains child with same tag"
  #   p errors = ct.match("exercises/html/check_div_same_children_exist.html","<html><head></head><body><div><h1>2017</h1><h2>2018</h2><h2>2019</h2></div></body></html>")
  #   assert_equal errors.empty? , true
  # end
  #
  # def test_html_check_div_same_empty_children_exist_error
  #   ct = CodeTerminator::Html.new
  #   p "24 test if div dont contains child with same tag"
  #   p errors = ct.match("exercises/html/check_div_same_children_exist.html","<html><head></head><body><div><h1>2017</h1><h2>2018</h2></div></body></html>")
  #   assert_equal errors.empty? , false
  # end
  #
  # def test_html_check_empty_divs_exist_error
  #   ct = CodeTerminator::Html.new
  #   p "25 test if three divs exists in code, throw error"
  #   p errors = ct.match("exercises/html/check_empty_divs_exist.html","<html><head></head><body><div></div><div></div></body></html>")
  #   assert_equal errors.empty? , false
  # end
  #
  # def test_html_check_divs_exist
  #   ct = CodeTerminator::Html.new
  #   p "26 test if three divs exists in code"
  #   p errors = ct.match("exercises/html/check_divs_exist.html","<html><head></head><body><div><h1>2017</h1></div><div><h2>2017</h2></div><div><h2>2018</h2></div></body></html>")
  #   assert_equal errors.empty? , true
  # end
  #
  # def test_html_check_divs_exist_error
  #   ct = CodeTerminator::Html.new
  #   p "27 test if three divs exists in code but with different children, throw error"
  #   p errors = ct.match("exercises/html/check_divs_exist.html","<html><head></head><body><div><h1>2017</h1></div><div><h2>2017</h2></div><div></div></body></html>")
  #   assert_equal errors.empty? , false
  # end
  #
  # def test_html_check_divs_exist_error_2
  #   ct = CodeTerminator::Html.new
  #   p "28 test if three divs exists in code but move children to other divs, throw error"
  #   p errors = ct.match("exercises/html/check_divs_exist.html","<html><head></head><body><div><h1>2017</h1></div><div><h2>2017</h2><h2>2018</h2></div><div></div></body></html>")
  #   assert_equal errors.empty? , false
  # end
  #
  # def test_html_check_imgs_exist
  #   ct = CodeTerminator::Html.new
  #   p "28 test if img can be empty"
  #   p errors = ct.match("exercises/html/check_imgs_empty_exist.html","<html><head></head><body><img src='kitten.png'><img src='cat.png'></body></html>")
  #   assert_equal errors.empty? , true
  # end
  #
  # def test_html_check_imgs_exist_error
  #   ct = CodeTerminator::Html.new
  #   p "29 test if imgs can be empty and detect one is missing"
  #   p errors = ct.match("exercises/html/check_imgs_empty_exist.html","<html><head></head><body><img src=''></body></html>")
  #   assert_equal errors.empty? , false
  # end
  #
  # def test_html_check_divs_with_attributes_exist_error
  #   ct = CodeTerminator::Html.new
  #   p "30 test if divs have attribute detect if one is missing"
  #   # p errors = ct.match("exercises/html/check_imgs_empty_exist.html","<html><head></head><body><img src=''></body></html>")
  #   p errors = ct.match("exercises/html/check_divs_different_attribute_exist.html","<html><head><title>My Favorite Book</title></head><body><div id='title' class='about'><h1></h1><p></p></div></body></html>")
  #   assert_equal errors.empty? , false
  # end
  #
  # def test_html_check_divs_with_attributes_exist_error_2
  #   ct = CodeTerminator::Html.new
  #   p "31 test if divs have attribute detect if one is missing"
  #   # p errors = ct.match("exercises/html/check_imgs_empty_exist.html","<html><head></head><body><img src=''></body></html>")
  #   p errors = ct.match("exercises/html/check_divs_different_attribute_exist_error.html","<html><head><title>My Favorite Book</title></head><body><div id='title'><h1></h1></div><div class='about'><p></p></div></body></html>")
  #   assert_equal errors.count == 2 , true
  # end
  #
  # def test_html_check_divs_with_attributes_exist_error_3
  #   ct = CodeTerminator::Html.new
  #   p "32 test if divs have attribute detect if one is missing"
  #   # p errors = ct.match("exercises/html/check_imgs_empty_exist.html","<html><head></head><body><img src=''></body></html>")
  #   p errors = ct.match("exercises/issue22.html","<html><head><title>My Favorite Book</title></head><body><div id='title'><h1></h1></div><div class='about'><p></p></div><div class='contact'><p></p></div></body></html>")
  #   assert_equal errors.empty? , true
  # end
  #
  # def test_html_check_imgs_with_empty_alt_exist
  #   ct = CodeTerminator::Html.new
  #   p "26 test if three divs exists in code"
  #   errors = ct.match("exercises/issue24.html","<html><head></head><body><img src='apple' alt='fruit'><img src='banana' alt='more fruit'><img src='pear' alt='even more fruit'></body></html>")
  #   assert_equal errors.empty? , true
  # end
  #
  # def test_html_check_imgs_with_empty_alt_exist_error
  #   ct = CodeTerminator::Html.new
  #   p "26 test if three divs exists in code"
  #   errors = ct.match("exercises/issue24.html","<html><head></head><body><img src='apple' alt='fruit'><img src='banana' alt='more fruit'><img src='pe' alt='even more fruit'></body></html>")
  #   assert_equal errors.empty? , false
  # end
  #
  # def test_html_check_imgs_one_less_with_empty_alt_exist_error
  #   ct = CodeTerminator::Html.new
  #   p "26 test if three divs exists in code"
  #   errors = ct.match("exercises/issue24.html","<html><head></head><body><img src='apple' alt='fruit'><img src='banana' alt='more fruit'></body></html>")
  #   assert_equal errors.empty? , false
  # end
end
