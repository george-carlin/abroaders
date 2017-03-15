require 'cells_helper'

require 'abroaders/cell/options'

RSpec.describe Abroaders::Cell::Options do
  class CellWithOptions < Cell::ViewModel
    extend Abroaders::Cell::Options

    option :bar, optional: true
    # option :buzz, default: 'hello'

    def show
      bar || '"bar" not given'
    end
  end

  def render_options(opts = {})
    show(nil, opts.merge(__cell_class: CellWithOptions)).raw
  end

  class CellWithRequiredOption < Cell::ViewModel
    extend Abroaders::Cell::Options
    option :foo

    def show
      "foo: #{foo}"
    end
  end

  def render_required(opts = {})
    show(nil, opts.merge(__cell_class: CellWithRequiredOption)).raw
  end

  example 'required option' do
    expect(render_required(foo: 'hello')).to eq 'foo: hello'

    expect do
      render_required(not_foo: 'hello')
    end.to raise_error Abroaders::Cell::MissingOptionsError, /\bfoo\b/
  end

  example 'optional option' do
    expect(render_options(bar: 'algo')).to eq 'algo'

    # bar is optional
    expect(render_options(not_bar: 'yo')).to eq '"bar" not given'
  end

  example 'with :collection option' do
    expect do
      cell(CellWithRequiredOption, nil, collection: true)
    end.to raise_error Abroaders::Cell::MissingOptionsError, /\bfoo\b/

    expect do
      cell(CellWithRequiredOption, nil, foo: 'yo', collection: true)
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
