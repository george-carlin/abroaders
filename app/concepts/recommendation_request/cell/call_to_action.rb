class RecommendationRequest < RecommendationRequest.superclass
  module Cell
    # @param account [Account] the currently logged-in account. Must be able
    #   to request a rec, else an error will be raised TODO fix docs
    class CallToAction < Abroaders::Cell::RecommendationAlert
      property :people

      def initialize(account, opts = {})
        raise ArgumentError, "can't render #{self.class}" unless Policy.new(account).create?
        super
      end

      private

      def actions
        people_who_can_request = people.select { |p| Policy.new(p).create? }
        link_args = [
          'Request new card recommendations',
          { class: 'btn btn-success', id: 'new_rec_request_link' },
        ]

        case people_who_can_request.size
        when 2
          link_args.insert(1, '#')
          link_args.last[:data] = { form: true }
          extra = cell(SelectPersonForm, people_who_can_request)
        when 1
          type = people_who_can_request.first.type
          link_args.insert(1, new_recommendation_requests_path(person_type: type))
          extra = ''
        else raise 'this should never happen'
        end

        "#{link_to(*link_args)}#{extra}"
      end

      def header
        'Want to Earn More Rewards Points?'
      end

      def main_text
        'Our team of experts will review your travel plans, current points, '\
        'and cards, and recommend the best new card for you'
      end

      # The 'request new card recs' button shows a dropdown where they can
      # choose which person or people want a rec. Then when they submit that
      # form, they're taken to the confirmation survey.
      #
      # @!method self.call(people, options = {})
      #   @param people [Enumerable<Person>] the people who can request a rec
      class SelectPersonForm < Abroaders::Cell::Base
        def show
          render
        end

        private

        def person_select_form(&block)
          content_tag :div, id: 'new_rec_request_form', style: 'display:none;' do
            form_tag(
              new_recommendation_requests_path,
              class: 'form-inline',
              method: :get,
              &block
            )
          end
        end

        def person_select_field
          options = model.sort_by(&:type).reverse.each_with_object({}) do |person, h|
            # TODO XSS?
            # TODO this will cause a bug if the people have the same name :(
            h[person.first_name] = person.type
          end
          options['Both of us'] = 'both'

          select_tag(:person_type, options_for_select(options))
        end
      end
    end
  end
end
