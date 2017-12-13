require 'test_helper'

class TestController < ActionController::Base
end

class Rails::Sfc::Test < ActiveSupport::TestCase
  def setup
    paths = ActionController::Base.view_paths
    @assigns = { secret: "in the sauce" }
    @view = Class.new(ActionView::Base).new(paths, @assigns)

    @controller_view = TestController.new.view_context
  end

  test "a single file component can be loaded" do
    assert_equal "<h1>Hello</h1>", @view.render(template: 'components/my_component')
  end
end
