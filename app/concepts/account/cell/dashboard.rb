class Account < Account.superclass
  module Cell
    # The main user dashboard. For most users it's just a static page. For users
    # who have only just completed the onboarding survey, they'll see some
    # extra content, contained within the ForNewUser subclass (which itself
    # has three subclasses; see the class comments on those subclasses)
    #
    # @!self.call(account)
    class Dashboard < Abroaders::Cell::Base
      extend Abroaders::Cell::Result
      include ::Cell::Builder

      skill :account
      skill :actionable_recommendations

      # annoyingly, it seems like you can't nest calls to builds. I'd rather
      # just have this block choose between self/ForNewUser, then a 2nd
      # `builds` block in ForNewUser that chooses between Ready / Unready /
      # Ineligible. But it doesn't work. Possibly addition to cells itself?
      builds do |result|
        account = result['account']
        if account.people.any? { |p| !p.last_recommendations_at.nil? }
          self
        elsif account.people.any?(&:ready?)
          ForNewUser::Ready
        elsif account.people.any?(&:eligible?)
          ForNewUser::Unready
        else
          ForNewUser::Ineligible
        end
      end

      def show
        render view: 'dashboard' # use the same ERB file for all subclasses:
      end

      private

      def lead_text
        %[
          We are amped up to help you save on travel. <br/> Don't be shy to
          reach out if you have any questions.
        ]
      end

      def new_user_instructions
        ''
      end

      def owner_first_name
        ERB::Util.html_escape(account.owner_first_name)
      end

      def actionable_recs_modal
        if result['actionable_recommendations'].any? && cookies[:recommendation_timeout].nil?
          cell(ActionableRecsModal)
        else
          ''
        end
      end

      def welcome
        "Welcome to Abroaders, #{owner_first_name}."
      end

      # @!self.call(account)
      class ForNewUser < self
        property :people

        def new_user_instructions
          %[
            <div class="row new-user-instructions">
              <div class="col-xs-12 col-md-4 new-user-steps">
                <p class="completed">
                  1. Complete profile <i class="fa fa-check" aria-hidden="true"> </i>
                </p>
                #{steps}
              </div><!-- .new-user-steps -->

              <div class="col-xs-12 col-md-8 main-area">
                <p><b>What's next?</b></p>
                #{whats_next}
              </div>
            </div>

            <hr />
          ]
        end

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

        # Shown to new users who have at least one ready person on their account
        class Ready < self
          def current_step
            2
          end

          def lead_text
            t('dashboard.account.ready.title')
          end

          def step_2
            'Wait 24-48 hours'
          end

          def whats_next
            %[<p>#{t('dashboard.account.ready.message')}</p>]
          end
        end

        # Shown to new users who have at least one eligible person on their
        # account, but no ready people.
        class Unready < self
          def current_step
            2
          end

          def lead_text
            t('dashboard.account.eligible.title')
          end

          def step_2
            "Tell us when you're ready"
          end

          def whats_next
            %[
          <p>
            When you’re ready to apply for cards, just
            #{link_to 'let us know', edit_readiness_path} and an expert will pick
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
        class Ineligible < self
          def current_step
            2
          end

          def lead_text
            t('dashboard.account.ineligible.title')
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
