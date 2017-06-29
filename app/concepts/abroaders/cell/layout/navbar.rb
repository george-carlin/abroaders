module Abroaders::Cell
  class Layout < Layout.superclass
    # @!method self.call(_, options = {})
    #   @option options [Boolean] sidebar? is the sidebar rendered?
    #   @option options [Account] current_account
    #   @option options [Admin] current_admin
    class Navbar < Abroaders::Cell::Base
      include ::Cell::Builder

      builds do |_, options = {}|
        if options[:current_account] && options[:current_admin]
          AdminAsAccountNavbar
        elsif options[:current_account]
          AccountNavbar
        elsif options[:current_admin]
          AdminNavbar
        else
          SignedOutNavbar
        end
      end

      subclasses_use_parent_view!

      option :current_account, optional: true
      option :current_admin, optional: true
      option :sidebar?

      private

      def bars
        if sidebar?
          '<div class="header-link hide-menu visible-xs"><i class="fa fa-bars"></i></div>'
        else
          ''
        end
      end

      def logo_html_classes # override in subclasses
        ''
      end

      def logo_image_tag
        # Actual image size is 220x72, but display it at half the 'real' size
        # so it looks good on Retina displays.
        image_tag 'abroaders-logo-grey-md.png', size: '110x36', alt: 'Abroaders'
      end

      def search_form # override in subclasses
        ''
      end

      def small_logo
        <<-HTML
        <div class="small-logo" #{'style="padding-left: 20px"' if !sidebar?}>
          <span class="text-primary">Abroaders</span>
        </div>
        HTML
      end

      def username_tag # override in subclasses
        ''
      end

      class SignedInNavbar < self
        private

        # TODO XSS?
        def username_tag
          content_tag :li, username, class: :text
        end

        def links
          content_tag :li do
            link_to sign_out_path, method: :delete, id: 'sign_out_link' do
              raw(fa_icon('sign-out'))
            end
          end
        end

        def mobile_links
          content_tag :li do
            link_to('Sign out', sign_out_path, method: :delete)
          end
        end
      end

      class AccountNavbar < SignedInNavbar
        private

        def username
          current_account.email
        end

        def sign_out_path
          destroy_account_session_path
        end
      end

      class AdminNavbar < SignedInNavbar
        private

        def username
          current_admin.email
        end

        def search_form
          cell(AdminArea::Accounts::Cell::SearchForm)
        end

        def sign_out_path
          destroy_admin_session_path
        end

        def logo_html_classes
          'admin-navbar'
        end
      end

      class AdminAsAccountNavbar < AdminNavbar
        def username
          "<b>#{current_admin.email}</b> as #{current_account.email}"
        end

        def search_form
          ''
        end

        def sign_out_path
          destroy_account_session_path
        end
      end

      class SignedOutNavbar < self
        private

        def bars
          ''
        end

        def links
          raw_links.map do |text, href|
            content_tag :li do
              link_to text, href, class: 'text'
            end
          end.join
        end

        def mobile_links
          raw_links.map do |text, href|
            content_tag :li do
              link_to text, href
            end
          end.join
        end

        def raw_links
          [
            ['Sign in', new_account_session_path],
            ['Sign up', new_account_registration_path],
          ]
        end
      end
    end
  end
end
