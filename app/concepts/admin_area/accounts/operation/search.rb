module AdminArea
  module Accounts
    module Operation
      # find accounts where the email address, phone number, or name of either
      # person matches the search query (non-case-sensitive). The results are
      # available on the 'collection' key of the result object.
      #
      # Takes one param called `:query`.
      class Search < Trailblazer::Operation
        self['account.class'] = Account
        extend Contract::DSL

        step :set_query
        step :find_accounts!

        private

        def set_query(opts, params:, **)
          opts['query'] = params.fetch(:accounts).fetch(:search).squish
        end

        def find_accounts!(opts, query:, **)
          # this is very far from ideal, but I think we can get away with it for now:
          ids = opts['account.class'].find_by_sql(
            [
              %[
              SELECT DISTINCT accounts.id
              FROM accounts, people
              WHERE accounts.id = people.account_id
              AND concat_ws(' ', accounts.email, people.first_name, accounts.phone_number_normalized)
              ILIKE ?
              ],
              "%#{query}%",
            ],
          ).pluck(:id)
          opts['collection'] = \
            opts['account.class'].order('email ASC').where(id: ids)
        end
      end
    end
  end
end
