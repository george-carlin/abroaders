module Readiness
  module Cell
    # @!method self.call(account, options = {})
    #   @param account [Account] the currently logged-in account
    class Survey < Abroaders::Cell::Base
      include Escaped

      property :companion
      property :companion_first_name
      property :couples?
      property :eligible_people
      property :owner
      property :owner_first_name
      property :people

      def title
        'Readiness'
      end

      private

      def default_type
        @default_type ||= begin
                            case eligible_people.count
                            when 2 then 'both'
                            when 1 then eligible_people.first.type
                            else raise 'this should never happen'
                            end
                          end
      end

      def everyone_eligible?
        @everyone_eligible ||= people.all?(&:eligible?)
      end

      def radio_group(person_type, label_text)
        checked = person_type.to_s == default_type
        button  = radio_button_tag :person_type, person_type, checked
        content_tag :div, class: 'radio' do
          content_tag :label do
            "#{button} #{label_text}"
          end
        end
      end

      def radio_for_both
        return '' unless couples? && everyone_eligible?
        label = "Both #{owner_first_name} and #{companion_first_name} are ready now"
        radio_group(:both, label)
      end

      def radio_for_owner
        return '' unless owner.eligible?
        label = if couples? && companion.eligible?
                  "#{owner_first_name} is ready now but #{companion_first_name} isn't"
                else
                  "Yes - I'm ready now"
                end
        radio_group(:owner, label)
      end

      def radio_for_companion
        return '' unless couples? && companion.eligible?
        label = if owner.eligible?
                  "#{companion_first_name} is ready now but #{owner_first_name} isn't"
                else
                  "Yes - I'm ready now"
                end
        radio_group(:companion, label)
      end

      def radio_for_neither
        label = if couples? && everyone_eligible?
                  'Neither of us is ready yet'
                else
                  "No - I'm not ready yet"
                end
        radio_group(:neither, label)
      end
    end
  end
end
