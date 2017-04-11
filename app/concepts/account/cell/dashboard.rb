class Account < Account.superclass
  module Cell
    # The main user dashboard. For most users it's just a static page. For users
    # who have only just completed the onboarding survey, they'll see some
    # extra content, contained within the ForNewUser subclass (which itself
    # has three subclasses; see the class comments on those subclasses)
    #
    # @!self.call(account)
    class Dashboard < Abroaders::Cell::Base
      include Escaped

      property :actionable_card_recommendations?
      property :unresolved_recommendation_requests?
      property :owner_first_name

      def show
        render view: 'dashboard' # use the same ERB file for all subclasses:
      end

      private

      def next_steps
        cell(NextSteps, model)
      end

      def lead_text
        if model.unresolved_recommendation_requests?
          t('dashboard.account.unresolved_rec_req.title')
        elsif model.card_recommendations.any?
          "We are amped up to help you save on travel. <br/> Don't be shy to "\
          'reach out if you have any questions'
        elsif model.eligible_people.any?
          t('dashboard.account.eligible.title')
        else
          t('dashboard.account.ineligible.title')
        end
      end

      def actionable_recs_modal
        if actionable_card_recommendations? && cookies[:recommendation_timeout].nil?
          cell(ActionableRecsModal)
        else
          ''
        end
      end

      def welcome
        "Welcome to Abroaders, #{owner_first_name}."
      end

      # @!method self.call(account, options = {})
      class NextSteps < Abroaders::Cell::Base
        include ::Cell::Builder

        builds do |account|
          if account.unresolved_recommendation_requests?
            UnresolvedRequests
          elsif account.card_recommendations.any?
            self
          elsif account.eligible_people.any?
            NewAndEligible
          else
            NewAndIneligible
          end
        end

        property :people

        # return an empty string if this isn't a subclass
        def show
          return '' if instance_of?(NextSteps)
          render view: 'dashboard/next_steps'
        end

        private

        %w[main_text step_2 whats_next].each do |meth|
          define_method meth do
            raise NotImplementedError, "subclasses must implement ##{meth}"
          end
        end

        def step_3
          'Apply for card'
        end

        def step_4
          'Earn bonus points'
        end

        def step_5
          'Book travel'
        end

        def steps
          [step_2, step_3, step_4, step_5].compact.each_with_index.map do |step_text, i|
            # step 1 is the same for all three subclasses, so it's hardcoded into
            # the HTML in #show. Start counting from step 2:
            step_number = i + 2
            css_class = current_step == step_number ? 'next' : ''
            %[<p class='#{css_class}'>#{step_number}. #{step_text}</p>]
          end.join
        end

        # Shown to anyone (not just new users) who has an unresolved request
        #
        # I suppose this shouldn't really be a subclass of ForNewUser because
        # it can be shown to non-new users, but originally that wasn't the
        # case, so let's keep the inheritance structure the same rather than
        # uproot the legacy code.
        #
        # @!self.call(account)
        class UnresolvedRequests < self
          def current_step
            2
          end

          def step_2
            'Wait 24-48 hours'
          end

          def whats_next
            %[<p>#{t('dashboard.account.unresolved_rec_req.message')}</p>]
          end
        end

        # Shown to new users who have at least one eligible person on their
        # account, but haven't made a rec request yet.
        #
        # @!self.call(account)
        class NewAndEligible < self
          def current_step
            2
          end

          def link_to_new_rec_request
            ppl = people.select { |p| RecommendationRequest::Policy.new(p).create? }
            # FIXME this must be at least the third time I've written a case
            # statement like this. DRY it somehow.
            person_type = case ppl.size
                          when 2 then 'both'
                          when 1 then ppl[0].type
                          else raise 'this should never happen'
                          end
            link_to 'let us know', new_recommendation_requests_path(person_type: person_type)
          end

          def step_2
            "Tell us when you're ready"
          end

          def whats_next
            %[
          <p>
            When you’re ready to apply for cards, just
            #{link_to_new_rec_request} and an expert will pick
            the best cards to maximize your travel savings. If we don’t hear back,
            we’ll remind you in about a month.
          </p>

          <p>
            In the meantime, we’ll track the
            #{link_to 'points', balances_path},
            #{link_to 'travel plans', travel_plans_path}
            and #{link_to 'cards', cards_path} you added to your account
            and send you an alert

            <span
              class="tooltip-btn"
              data-toggle="tooltip"
              title="Alerts might include easy ways to earn free points, cheap flights
              to places you have listed in your travel plans, or advice about using
              your points if you have enough to travel with already."
            >(?)</span>

            if we find any good deals for you.
          </p>]
          end
        end

        # Shown to new users who have no eligible people on their account
        #
        # @!self.call(account)
        class NewAndIneligible < self
          def current_step
            2
          end

          def step_2
            'Earn points'
          end

          def step_3
            'Travel'
          end

          def step_4
            nil
          end

          def step_5
            nil
          end

          def whats_next
            %[<p>#{t('dashboard.account.ineligible.message')}</p>]
          end
        end
      end

      class ActionableRecsModal < Abroaders::Cell::Base
        private

        def container(&block)
          content_tag(
            :div,
            'tabindex': '-1',
            'aria-labelledby': 'actionable_recommendations_notification_modal_label',
            'data-backdrop': 'static',
            'role': 'dialog',
            class: 'modal fade in',
            id: 'actionable_recommendations_notification_modal',
          ) do
            content_tag :div, class: 'modal-dialog' do
              content_tag :div, class: 'modal-content', &block
            end
          end
        end

        def link_to_continue
          link_to 'Continue', cards_path, class: 'btn btn-primary'
        end
      end
    end
  end
end
