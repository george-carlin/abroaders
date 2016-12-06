class Card < ApplicationRecord
  class Operation < Trailblazer::Operation
  end

  class Update < Operation
    contract Card::Contract

    def process(params)
      validate(params[:card]) do |f|
        f.sync
        f.model.opened_at = f.model.opened_at.end_of_month
        # FIXME technical debt ahoy
        if Dry::Types::Coercions::Form::TRUE_VALUES.include?(params[:card][:closed].to_s)
          f.model.closed_at = f.model.closed_at.end_of_month
        else
          f.model.closed_at = nil
        end
        f.model.save
      end
    end

    private

    def model!(params)
      params[:current_account].cards.find(params[:id])
    end
  end

  module Admin
    class Create < Operation
      contract ::Card::Admin::Contract

      def process(params)
        validate(params[:card]) do |f|
          f.sync
          f.model.opened_at = f.model.opened_at.end_of_month
          # FIXME technical debt ahoy
          if Dry::Types::Coercions::Form::TRUE_VALUES.include?(params[:card][:closed].to_s)
            f.model.closed_at = f.model.closed_at.end_of_month
          else
            f.model.closed_at = nil
          end
          f.model.save
        end
      end

      private

      def model!(params)
        params[:person].cards.new
      end
    end
  end
end
