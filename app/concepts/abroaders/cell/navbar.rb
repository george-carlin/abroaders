class Abroaders::Cell < Trailblazer::Cell
  class Navbar < Trailblazer::Cell
    include ::Cell::Builder

    builds do |user|
      case user
      when Account then AccountNavbar
      when Admin   then AdminNavbar
      when nil then SignedOutNavbar
      end
    end

    def show
      root_path

      render view: 'navbar' # use the same ERB file even in subclasses
    end

    private

    def bars
      if sidebar?
        '<div class="header-link hide-menu"><i class="fa fa-bars"></i></div>'
      else
        ''
      end
    end

    def search_form
      ''
    end

    def pad_logo?
      !sidebar?
    end

    def logo
      cell(Logo)
    end

    def username
      ''
    end

    def notifications
      ''
    end

    class SignedInNavbar < self
      def username
        content_tag :li, model.email, class: :text
      end

      def links
        content_tag :li do
          link_to sign_out_path, method: :delete, id: 'sign_out_link' do
            raw('<i class="pe-7s-upload pe-rotate-90"></i>')
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

      def sidebar?
        model.onboarded?
      end

      def notifications
        model.onboarded? ? cell(Notification::Cell::List, model) : super
      end

      def sign_out_path
        destroy_account_session_path
      end
    end

    class AdminNavbar < SignedInNavbar
      private

      def search_form
        cell(AdminArea::Account::Cell::SearchForm)
      end

      def sidebar?
        true
      end

      def sign_out_path
        destroy_admin_session_path
      end

      def logo
        cell(Logo, model)
      end
    end

    class SignedOutNavbar < self
      private

      def bars
        ''
      end

      def sidebar?
        false
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
