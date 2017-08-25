module Onboarding
  module Cell
    module Account
      class Type < Abroaders::Cell::Base
        # the user's next destination
        option :destination

        def show
          content_tag :div, id: 'account_type_forms' do
            content_tag :div, class: 'row' do
              cell(Header, nil, destination: destination).to_s +
                cell(Onboarding::Cell::Account::Type::SoloForm).to_s +
                cell(Onboarding::Cell::Account::Type::CouplesForm).to_s
            end
          end
        end

        def title
          'Select Account Type'
        end

        # the header for the account type page. no model.
        #
        # options:
        #   destination: (optional) the destination of the user's next trip
        class Header < Abroaders::Cell::Base
          option :destination, optional: true

          private

          def html_classes
            'col-xs-12 col-md-8 col-md-offset-2 account_type_select_header'
          end
        end

        class Form < Abroaders::Cell::Base
          private

          def form_tag(&block)
            super(
              type_account_path,
              class: html_classes,
              data: { owner_first_name: current_account.owner_first_name },
              id: html_id,
              &block
            )
          end

          def html_classes
            'account_type_form hpanel col-xs-12 col-sm-6 col-md-5 col-lg-4'
          end

          def html_id
            raise NotImplementedError
          end
        end

        class SoloForm < Form
          private

          def html_classes
            "#{super} col-md-offset-1 col-lg-offset-2"
          end

          def html_id
            'solo_account_form'
          end
        end

        class CouplesForm < Form
          private

          def html_id
            'couples_account_form'
          end
        end
      end
    end
  end
end
