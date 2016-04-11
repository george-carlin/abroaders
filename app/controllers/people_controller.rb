class PeopleController < NonAdminController

  def index
    render html: "<pre>#{current_account.people.map(&:attributes).to_yaml}</pre>".html_safe
  end

end
