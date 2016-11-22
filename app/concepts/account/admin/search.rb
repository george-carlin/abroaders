module Account::Admin
  class Search
    def self.call(query:)
      # this is very far from ideal, but I think we can get away with it for now:
      ids = Account.find_by_sql(
        [
          %[
            SELECT DISTINCT accounts.id
            FROM (
              accounts LEFT OUTER JOIN phone_numbers
              ON phone_numbers.account_id = accounts.id
            ), people
            WHERE accounts.id = people.account_id
            AND concat_ws(' ', accounts.email, people.first_name, phone_numbers.normalized_number)
            ILIKE ?
          ],
          "%#{query}%",
        ],
      ).pluck(:id)
      Account.includes(:phone_number).order("email ASC").where(id: ids)
    end
  end
end
