module Onboarding
  module Cell
    module Account
      # model: TRB result object
      #
      # key:
      #   destinations: the user's next destination
      class Type < Trailblazer::Cell
        def show
          content_tag :div, id: 'account_type_forms' do
            content_tag :div, class: 'row' do
              cell(Header, nil, destination: model['destination']).to_s +
                cell(Onboarding::Cell::Account::Type::SoloForm).to_s +
                cell(Onboarding::Cell::Account::Type::CouplesForm).to_s
            end
          end
        end

        # the header for the account type page. no model.
        #
        # options:
        #   destination: (optional) the destination of the user's next trip
        class Header < Trailblazer::Cell
          private

          def destination
            options[:destination]
          end

          def html_classes
            'col-xs-12 col-md-8 col-md-offset-2 account_type_select_header'
          end

          def text
            result = 'Abroaders will help you earn the right points for your '
            result << if destination.nil?
                        'next trip'
                      else
                        "trip to #{destination.name}."
                      end
            result
          end
        end

        class Form < Trailblazer::Cell
          include BootstrapOverrides::Overrides

          private

          def form_tag(&block)
            super(type_account_path, id: html_id, class: html_classes, &block)
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
