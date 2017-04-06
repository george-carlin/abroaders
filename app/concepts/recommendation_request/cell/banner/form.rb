class RecommendationRequest < RecommendationRequest.superclass
  module Cell
    class Banner < Banner.superclass
      # @!method self.call(account, options = {})
      #   @param account [Account] the currently logged-in account
      class Form < Abroaders::Cell::Base
        include ::Cell::Builder

        builds do |account|
          # How many people on the account can currently make a new request?
          case account.eligible_people.select { |p| Policy.new(p).create? }.count
          # If it's 0, no need to do anything, so dont show the form at all:
          when 0 then Nothing
          when 1
            # Temporary solution. FIXME
            if account.eligible_people.many?
              Nothing
            else
              ForOnePerson
            end
          else
            ForTwoPeople
          end
        end

        property :companion
        property :couples?
        property :owner
        property :eligible_people

        def request_new_recs_btn_text
          'Request new card recommendations'
        end

        class ForOnePerson < self
          attr_reader :person

          def initialize(account, options = {})
            # Figure out which person is the one who can make a request, and
            # memoize it.
            #
            # To stay defensive, make sure there's exactly one such person.
            #
            # This method kinda duplicates the logic in the 'builds' block of
            # the parent class, but it'll do for now :/
            people = account.eligible_people.select { |p| Policy.new(p).create? }
            raise 'there must be exactly one person' unless people.length == 1
            @person = people[0]
            super
          end

          def show
            content_tag :div, class: 'col-xs-12' do
              button_to(
                request_new_recs_btn_text,
                recommendation_requests_path(person_type: person.type),
                class: 'btn btn-primary',
              )
            end
          end
        end

        class ForTwoPeople < self
          private

          def person_select_form
            return '' unless couples? && people.all?(&:eligible?)

            content_tag id: 'new_rec_request_form', class: 'col-xs-12', style: 'display:none;' do
              form_tag(recommendation_requests_path, class: 'form-inline', &block)
            end
          end

          def person_select_field
            select_tag(
              :person_type,
              options_for_select(
                owner.first_name => :owner,
                companion.first_name => :companion,
                "Both of us" => :both,
              ),
            )
          end
        end

        # render an empty string (builder uses this cell when we don't want to
        # show the form at all.)
        class Nothing < Abroaders::Cell::Base
          def show
            ''
          end
        end
      end
    end
  end
end
