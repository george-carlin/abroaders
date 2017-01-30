class Card < ApplicationRecord
  module Cell
    class Index < Trailblazer::Cell
      # Takes options :account and :person. If the account is a solo account,
      # returns an empty string If it's a couples account, returns an H3
      # header with the text 'Person Name's Cards'
      class Subheader < Trailblazer::Cell
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
    end
  end
end
