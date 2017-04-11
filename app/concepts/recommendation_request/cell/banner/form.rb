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
          when 0 then nil
          when 1 then ForOnePerson
          when 2 then ForTwoPeople
          else raise 'this should never happen'
          end
        end

        property :companion
        property :couples?
        property :owner
        property :eligible_people

        # Form (as opposed to a subclass) is rendered when we don't want to
        # display anything (because no-one can request a rec). Subclasses
        # must override #show
        def show
          ''
        end

        def request_new_recs_btn_text
          'Request new card recommendations'
        end

        # The 'request new card recs' button is just a link directly to the
        # confirmation survey for the appropriate person.
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
              link_to(
                request_new_recs_btn_text,
                new_recommendation_requests_path(person_type: person.type),
                class: 'btn btn-primary',
              )
            end
          end

          private

          def request_new_recs_btn_text
            if couples?
              "Request new card recommendations for #{escape(person.first_name)}"
            else
              super
            end
          end
        end

        # The 'request new card recs' button shows a dropdown where they can
        # choose which person or people want a rec, THEN when they submit this
        # form they're taken to the confirmation survey
        class ForTwoPeople < self
          def show
            render
          end

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
      end
    end
  end
end
