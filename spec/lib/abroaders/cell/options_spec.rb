require 'cells_helper'

require 'abroaders/cell/options'

RSpec.describe Abroaders::Cell::Options do
  class MyCell < Cell::ViewModel
    extend Abroaders::Cell::Options

    option :foo
    option :bar, optional: true

    def show
      result = "foo: #{foo}"
      result << ", bar: #{bar}" if bar
      result
    end
  end

  example 'required and optional' do
    expect do
      cell(MyCell, nil, bar: 'present')
    end.to raise_error Abroaders::Cell::MissingOptionsError, /\bfoo\b/

    instance = show(nil, foo: 'something', bar: 'algo', __cell_class: MyCell)
    expect(instance.raw).to eq 'foo: something, bar: algo'

    # bar is optional
    expect do
      cell(MyCell, nil, foo: 'something')
    end.not_to raise_error
  end

  example 'with :collection option' do
    expect do
      cell(MyCell, nil, bar: 'yo', collection: true)
    end.to raise_error Abroaders::Cell::MissingOptionsError, /\bfoo\b/

    expect do
      cell(MyCell, nil, foo: 'yo', collection: true)
    end.not_to raise_error
  end

  example 'when cell is nested in another cell' do # bug fix
    class WrapperCell < Cell::ViewModel
      def basic
        "<wrap>#{cell(MyCell, nil, foo: model)}</wrap>"
      end

      def error # foo is missing:
        "<wrap>#{cell(MyCell, nil, bar: model)}</wrap>"
      end

      def collection
        "<wrap>#{cell(MyCell, foo: model, collection: [1, 2])}</wrap>"
      end

      def collection_error # foo is missing:
        "<wrap>#{cell(MyCell, bar: model, collection: [1, 2])}</wrap>"
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
