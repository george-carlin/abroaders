module CardAccountsHelper
  def card_accounts_index_subheader(person)
    "#{person.first_name}'s Cards"
  end

  def options_for_person_select(account)
    account.people.map{ |person| [person.first_name, person.id] }
  end
end
