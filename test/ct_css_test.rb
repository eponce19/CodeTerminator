require 'test_helper'
require 'Crass'
require 'css_parser'


class CodeTerminatorCssTest < Minitest::Test
  def test_css_background_image_correct
      source_code = "exercises/css/lesson0.css"
      code = "body{ background-image: ; background-color: lightblue; }"
      ct = CodeTerminator::Css.new
      result = ct.match(source_code, code)
      assert_equal result.empty? , true
  end
  def test_css_no_background_image
      source_code = "exercises/css/lesson0.css"
      code = "body{ background-color: lightblue; }"
      ct = CodeTerminator::Css.new
      result = ct.match(source_code, code)
      assert_equal result.empty? , false
  end
  def test_css_no_background_image_any_value
      source_code = "exercises/css/lesson0.css"
      code = "body{ background-image: url('cat.jpg'); background-color: lightblue; }"
      ct = CodeTerminator::Css.new
      result = ct.match(source_code, code)
      assert_equal result.empty? , true
  end
  def test_css_background_image_with_value_incorrect
      source_code = "exercises/css/lesson0_w.css"
      code = "body{ background-image: ; background-color: lightblue; }"
      ct = CodeTerminator::Css.new
      result = ct.match(source_code, code)
      assert_equal result.empty? , false
  end
  def test_css_background_image_with_value
      source_code = "exercises/css/lesson0_w.css"
      code = "body{ background-image: url('paper.jpg'); background-color: lightblue; }"
      ct = CodeTerminator::Css.new
      result = ct.match(source_code, code)
      assert_equal result.empty? , true
  end

  def test_css_lesson_1_1_correct
      source_code = "exercises/css/lesson1_1.css"
      code = "#border{border-color:green; border-style:solid;}"
      ct = CodeTerminator::Css.new
      result = ct.match(source_code, code)
      assert_equal result.empty? , true
  end
  def test_css_lesson_1_1_incorrect
      source_code = "exercises/css/lesson1_1.css"
      code = "#border{border-color:red; border-style:solid;}"
      ct = CodeTerminator::Css.new
      result = ct.match(source_code, code)
      assert_equal result.empty? , false
  end
  def test_css_lesson_1_1_incorrect_blank
      source_code = "exercises/css/lesson1_1.css"
      code = "#border{}"
      ct = CodeTerminator::Css.new
      result = ct.match(source_code, code)
      assert_equal result.empty? , false
  end


  def test_css_lesson_1_2_correct
      source_code = "exercises/css/lesson1_2.css"
      code = "ul{width: 10px;height: 5px;background-color: red;}"
      ct = CodeTerminator::Css.new
      result = ct.match(source_code, code)
      assert_equal result.empty? , true
  end
  def test_css_lesson_1_2_incorrect
      source_code = "exercises/css/lesson1_2.css"
      code = "ul{height: 5px;background-color: red;}"
      ct = CodeTerminator::Css.new
      result = ct.match(source_code, code)
      assert_equal result.empty? , false
  end
  def test_css_lesson_1_2_incorrect_blank
      source_code = "exercises/css/lesson1_2.css"
      code = "ul{}"
      ct = CodeTerminator::Css.new
      result = ct.match(source_code, code)
      assert_equal result.empty? , false
  end



  def test_css_lesson_1_5_correct
      source_code = "exercises/css/lesson1_5.css"
      code = "img{
        background-color:blue;
        padding: 3px;
      }

      h1{
        margin:0px;
        background-color:red;
        padding: 3px;
      }

      p{
        margin:0px;
        background-color:green;
        padding: 3px;
      }"
      ct = CodeTerminator::Css.new
      result = ct.match(source_code, code)
      assert_equal result.empty? , true
  end
  def test_css_lesson_1_5_incorrect
      source_code = "exercises/css/lesson1_5.css"
      code = "img{
        background-color:blue;
        padding: 3px;
      }

      p{
        margin:0px;
        background-color:green;
        padding: 3px;
      }"
      ct = CodeTerminator::Css.new
      result = ct.match(source_code, code)
      assert_equal result.empty? , false
  end
  def test_css_lesson_1_5_incorrect_blank
      source_code = "exercises/css/lesson1_5.css"
      code = "img{
        background-color:blue;
        padding: 30px;
      }

      h1{
        margin:0px;
        background-color:red;
        padding: 30px;
      }

      p{
        margin:0px;
        background-color:green;
        padding: 30px;
      }"
      ct = CodeTerminator::Css.new
      result = ct.match(source_code, code)
      assert_equal result.empty? , false
  end
end
