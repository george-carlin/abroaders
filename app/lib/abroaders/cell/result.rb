module Abroaders
  module Cell
    class MissingSkillError < StandardError
      def initialize(missing_skill)
        super "result is missing skill `#{missing_skill}`"
      end
    end

    # experimental. This module is for use with cells which take a TRB
    # Result object as their model. It gives you an easy way to define getter
    # methods for the data accessible using `[]` on the result. I'm calling
    # them 'skills' because that's what the TRB docs use.
    #
    # Also aliases `model` to `result` for convenience.
    #
    #     class Person::Cell::Shoe < Abroaders::Cell::Base
    #       extend Abroaders::Cell::Result
    #       skill :person
    #       # use `as` to get a different method name:
    #       skill :regions_of_interest, as: :rois
    #
    #       # the above is equivalent to:
    #
    #       alias result model
    #
    #       private
    #
    #       def person
    #         # we passed the symbol `:person` to `skill` above, but skill
    #         # looks for the data with a string key:
    #         result['person']
    #       end
    #
    #       def rois
    #         result['regions_of_interest']
    #       end
    #     end
    #
    #     cell(TravelPersonSummary, nil)
    #     # => MissingOptionsError missing option 'editable'
    module Result
      def self.extended(base)
        base.class_eval do
          alias_method :result, :model
        end
      end

      def skill(name, as: nil)
        method_name = as || name

        define_method method_name do
          result[name.to_s] || raise(MissingSkillError, name)
        end

        private method_name
      end
    end
  end
end
