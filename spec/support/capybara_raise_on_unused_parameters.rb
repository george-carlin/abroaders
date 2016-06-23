# If you pass unused parameters to a Capybara selector, e.g.:
#
#     # Note the missing 'href:'
#     is_expected.to have_link "Home", root_path
#
# ... you can get false positives. Capybara will print a warning when you do
# this, but I don't think that's enough; I want these tests to fail explicitly.
# The only solution is to monkey-patch Capybara::Queries::SelectorQuery so that
# it raises an error rather than a warning. Of course, this is hacky behaviour
# that could easily break on the next Capybara upgrade, so run a quick check
# beforehand to make sure a developer remembers this and keeps everything
# up-to-date if we upgrade Capybara.

if Capybara::VERSION != "2.7.1"
  raise "You've upgraded Capybara from version 2.7.1. Make sure that the "\
        "monkey-patch in #{__FILE__} still works, and update/remove this "\
        "notice (or remove the monkey patch) as necessary"
end

module Capybara
  module Queries
    class SelectorQuery
      def warn(*messages)
        if messages.first =~ /\AUnused parameters/
          raise messages.first
        else
          super
        end
      end
    end
  end
end
