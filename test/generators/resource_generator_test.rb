require 'test_helper'
require 'rails/generators'
require_relative '../../lib/generators/cardboard/resource/resource_generator.rb'


class MockModel
  def self.column_names
    %w{foo bar baz}
  end
end

class ResrouceGeneratorTest < Rails::Generators::TestCase
  tests Cardboard::Generators::ResourceGenerator
  destination File.expand_path("../../tmp", File.dirname(__FILE__));
  setup :prepare_destination

  test "All files coppied over" do
    view_path = "vendor/cardboard/views/cardboard"
    run_generator ["mock_model"]
    assert_file "app/controllers/cardboard/mock_models_controller.rb"
    assert_file "#{view_path}/mock_models/index.html.erb"
    assert_file "#{view_path}/mock_models/_fields.html.erb"
    assert_file "#{view_path}/mock_models/edit.html.erb"
    assert_file "#{view_path}/mock_models/new.html.erb"
  end

  test "Files can be slim files" do
    view_path = "vendor/cardboard/views/cardboard"
    run_generator ["mock_model", "--markup=slim"]
    assert_file "app/controllers/cardboard/mock_models_controller.rb"
    assert_file "#{view_path}/mock_models/index.html.slim"
    assert_file "#{view_path}/mock_models/_fields.html.slim"
    assert_file "#{view_path}/mock_models/edit.html.slim"
    assert_file "#{view_path}/mock_models/new.html.slim"
  end

  test "The overwire flag will move the files into the app" do
    view_path = "app/views/cardboard"
    run_generator ["mock_model", "--overwrite"]
    assert_file "app/controllers/cardboard/mock_models_controller.rb"
    assert_file "#{view_path}/mock_models/index.html.erb"
    assert_file "#{view_path}/mock_models/_fields.html.erb"
    assert_file "#{view_path}/mock_models/edit.html.erb"
    assert_file "#{view_path}/mock_models/new.html.erb"
  end
end
