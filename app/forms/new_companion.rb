class NewCompanion < Form

  attr_accessor :first_name

  def initialize(account)
    @account = account
  end

  def self.name
    "Companion"
  end

  def to_param
    @companion&.id.to_s
  end

  def save
    super do
      @companion = @account.people.create!(
        first_name: first_name,
        main: false,
      )
    end
  end

  validates :first_name,
    presence: true,
    length: { maximum: ::Person::NAME_MAX_LENGTH }

end
