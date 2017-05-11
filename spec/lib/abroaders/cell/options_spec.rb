require 'cells_helper'

require 'abroaders/cell/options'

RSpec.describe Abroaders::Cell::Options do
  class CellWithOptions < Cell::ViewModel
    include Abroaders::Cell::Options

    option :bar, optional: true

    def show
      bar || '"bar" not given'
    end
  end

  class CellWithRequiredOption < Cell::ViewModel
    include Abroaders::Cell::Options
    option :foo

    def show
      "foo: #{foo}"
    end
  end

  example 'required option' do
    expect(raw_cell(CellWithRequiredOption, nil, foo: 'hello')).to eq 'foo: hello'

    expect do
      raw_cell(CellWithRequiredOption, nil, not_foo: 'hello')
    end.to raise_error Abroaders::Cell::MissingOptionsError, /\bfoo\b/
  end

  example 'optional option' do
    expect(raw_cell(CellWithOptions, nil, bar: 'algo')).to eq 'algo'

    # bar is optional
    expect(raw_cell(CellWithOptions, nil, not_bar: 'algo')).to eq '"bar" not given'
  end

  example 'with :default' do
    class MyCell < Trailblazer::Cell
      include Abroaders::Cell::Options
      option :buzz, default: 'hello'

      def show
        buzz
      end
    end

    expect(raw_cell(MyCell)).to include 'hello'
    expect(raw_cell(MyCell, nil, buzz: 'hola')).to include 'hola'
  end

  example 'with :collection option' do
    expect do
      cell(CellWithRequiredOption, collection: [1, 2]).()
    end.to raise_error Abroaders::Cell::MissingOptionsError, /\bfoo\b/

    expect do
      cell(CellWithRequiredOption, foo: 'yo', collection: [1, 2]).()
    end.not_to raise_error
  end

  example 'when cell is nested in another cell' do # bug fix
    class WrapperCell < Cell::ViewModel
      def basic
        "<wrap>#{cell(CellWithRequiredOption, nil, foo: model)}</wrap>"
      end

      def error # required key is missing:
        "<wrap>#{cell(CellWithRequiredOption, nil)}</wrap>"
      end

      def collection
        "<wrap>#{cell(CellWithRequiredOption, foo: model, collection: [1, 2])}</wrap>"
      end

      def collection_error # required key is missing:
        "<wrap>#{cell(CellWithRequiredOption, collection: [1, 2])}</wrap>"
      end
    end

    instance = cell(WrapperCell, 'string')

    expect do
      instance.error
    end.to raise_error Abroaders::Cell::MissingOptionsError, /\bfoo\b/
    expect do
      instance.collection_error
    end.to raise_error Abroaders::Cell::MissingOptionsError, /\bfoo\b/

    expect(instance.basic.to_s).to eq '<wrap>foo: string</wrap>'
    expect(instance.collection.to_s).to eq '<wrap>foo: stringfoo: string</wrap>'
  end
end
