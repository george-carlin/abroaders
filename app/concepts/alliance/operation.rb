require_dependency 'reform/form/dry'

class Alliance < ApplicationRecord
  class Create < Trailblazer::Operation
    include Model
    model Alliance, :create

    contract do
      feature Reform::Form::Coercion
      feature Reform::Form::Dry

      property :name, type: Types::Stripped::String
      property :order, type: ::Types::Form::Int

      validation do
        required(:name).filled { str? }
        optional(:order).maybe
      end
    end

    def process(params)
      validate params[:alliance] do |f|
        f.sync
        f.model.order ||= begin
          # TODO not sure this belongs in the 'process' method. Also this isn't
          # ideal as it doesn't use the next *unfilled* value.
          (Alliance.maximum(:order) || 0) + 1
        end
        f.model.save
      end
    end
  end
end
