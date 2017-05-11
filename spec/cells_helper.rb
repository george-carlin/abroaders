# I've tried to find a way of testing cells without having to load the
# entire rails environment every time, but there are two major barriers:
#
# 1. rspec-cells depends on Rails
# 2. almost all cells are contained under the namespace of an ActiveRecord model, e.g.
#
#     class Flight < Flight.superclass
#       module Cell
#         class Summary < Trailblazer::Cell
#         ...
#
#   There's no way to load that without loading `Flight`, and, as I've
#   discovered before, because of the way activerecord associations work I
#   basically can't load Flight without loading every other model. Bollocks
require 'rails_helper'

module Abroaders
  module RSpec
    module CellMacros
      # Extend the 'cell' macro so that you don't need to explicitly specify
      # the cell class.
      #
      # If the first argument is a cell class then the helper will work like
      # normal:
      #
      #     cell(MyCell, model, options)
      #     # => <#MyCell>
      #
      # Otherwise if just pass the model and options, it will be assumed
      # that the described_class is the cell class:
      #
      #     RSpec.describe MyCell do
      #       example '' do
      #         cell(model, options)
      #         # => <#MyCell>
      #       end
      #     end
      #
      # assume that `described_class` is the cell class.
      def cell(cell_or_model, *model_and_options)
        if cell_or_model.is_a?(Class) && cell_or_model.ancestors.include?(::Cell::ViewModel)
          cell_class = cell_or_model
          model = model_and_options[0]
          options = model_and_options[1] || {}
        else
          cell_class = described_class
          model = cell_or_model
          options = model_and_options[0] || {}
        end
        super(cell_class, model, options)
      end

      # The 'cell' method provided by rspec-cells will wrap the rendered string
      # in a Capybara::Node::Simple so that you can test it with matchers like
      # have_selector etc. This is fine, but sometimes a cell renders a really
      # simple string and you just want to test what that string equals.
      # Capybara::Simple::Node.to_s will include a bunch of extra shit like a
      # <doctype> and <body> tags.
      #
      # If you just want the raw string, you *could* render the cell directly
      # without using a helper:
      #
      #
      #   MyCell.(model).()
      #
      # ... but then you won't get the context object, so the cell can't e.g.
      # access routes. Use #raw_cell when you want to render the raw string
      # with no extra Capybara stuff but you still need the cell to access
      # the context object
      def raw_cell(cell_or_model, *model_and_options)
        body = cell(cell_or_model, *model_and_options).().all('body')[0]
        return '' if body.nil?
        body = body.native
        if body.children.count == 1 && body.children[0].name == 'p'
          body.children[0].inner_html
        else
          body.inner_html
        end
      end
    end
  end
end

# This is a heavily-modified version of the RSpec.configure block that's
# included by the `rspec-cells` gem:
RSpec.configure do |config|
  CELL_FILE_PATH = /\bcells?\b/

  config.include RSpec::Cells::ExampleGroup, file_path: CELL_FILE_PATH
  config.include RSpec::Cells::ExampleGroup, type: :cell
  # this must go below RSpec::Cells::ExampleGroup so our overrides work:
  config.include Abroaders::RSpec::CellMacros, file_path: CELL_FILE_PATH
  config.include Abroaders::RSpec::CellMacros, type: :cell

  Cell::Testing.capybara = true
end
