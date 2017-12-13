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
    assert_kind_of String, @view.render(template: 'test', formats: [:sfc])
  end
end
