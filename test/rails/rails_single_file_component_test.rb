require 'test_helper'

class TestController < ActionController::Base
end

class RailsSingleFileComponents::Test < ActiveSupport::TestCase
  def setup
    paths = ActionController::Base.view_paths
    @assigns = { secret: "in the sauce" }
    @view = Class.new(ActionView::Base).new(paths, @assigns)

    @controller_view = TestController.new.view_context
  end

  test "a single file component can be loaded" do
    assert_equal "<h1>Hello</h1>", @view.sfc_component('simple')
  end

  test "a missing file raises an error" do
    assert_raises RailsSingleFileComponents::MissingComponentException do
      @view.sfc_component('asdfasdf')
    end
  end

  test "a template can only contain a single top-level tag" do
    assert_raises RailsSingleFileComponents::CompilationException do
      @view.sfc_component('multiple_top_level_tags')
    end
  end
end
