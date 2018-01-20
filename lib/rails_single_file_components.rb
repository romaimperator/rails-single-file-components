# frozen_string_literal: true
$LOAD_PATH.unshift(File.expand_path('..', __FILE__))

require 'sass/css'

require 'rails_single_file_components/transform_pipelines/base'
require 'rails_single_file_components/transform_pipelines/style'
require 'rails_single_file_components/transform_pipelines/template'

require 'rails_single_file_components/rails_parts/style_processor'
require 'rails_single_file_components/rails_parts/railtie'
require 'rails_single_file_components/rails_parts/sfc_file_system_resolver'

require 'rails_single_file_components/data_attribute'
require 'rails_single_file_components/exceptions'
require 'rails_single_file_components/asset_compilation'
require 'rails_single_file_components/parser'
