class Card < Card.superclass
  module Cell
    class Index < Abroaders::Cell::Base
      # Takes options :account and :person. If the account is a solo account,
      # returns an empty string If it's a couples account, returns an H3
      # header with the text 'Person Name's Cards'
      class Subheader < Abroaders::Cell::Base
        def show
          if options[:account].couples?
            "<h3>#{first_name}'s Cards</h3>"
          else
            ''
          end
        end

        private

        def first_name
          ERB::Util.html_escape(options[:person].first_name)
        end
      end

      # @!method self.call(people, options = {})
      #   I tried to build this so that it took 'account' as the model and not
      #   the people, but I couldn't figure out how to prevent a shit-ton of
      #   N+1 query issues. Right now the @people ivar loaded in the controller
      #   avoids these issues, but when I convert that controller action to the
      #   proper TRB style I'm not sure how to solve the issue. Sticking
      #   something like in the controller doesn't work:
      #
      #      current_account.people.includes(
      #        :account,
      #        unresolved_card_recommendations: { product: :bank, offer: { product: :currency } },
      #      ).reload
      #
      #   (That's if `current_account` was passed to this cell.) It doesn't
      #   work because when the cell calls current_account.people it ignores
      #   the previous `includes` that were called on current_account.people.
      class CardRecommendations < Abroaders::Cell::Base
        def show
          content_tag :div, id: 'card_recommendations' do
            cell(ForPerson, collection: model)
          end
        end

        # @!method self.call(person, options = {})
        class ForPerson < Abroaders::Cell::Base
          include Escaped

          property :account
          property :first_name
          property :type
          property :unresolved_card_recommendations

          def show
            content_tag :div, id: "#{type}_card_recommendations" do
              header + recommendations
            end
          end

          private

          def header
            return '' unless account.couples?
            "<h3>#{first_name}'s Recommendations</h3>"
          end

          def recommendations
            if unresolved_card_recommendations.any?
              cell(
                CardRecommendation::Cell::UnresolvedRec,
                collection: unresolved_card_recommendations,
              ).join('<hr>') { |c| c }
            else
              "No recommendations for #{first_name}"
            end
          end
        end
      end
    end
  end
end
