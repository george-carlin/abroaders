class SignUp < ApplicationForm
  attribute :email,      String
  attribute :first_name, String
  attribute :password,   String

  attr_reader :account

  def clean_up_passwords
    self.password = self.password_confirmation = nil
  end

  def email=(new_email)
    super(new_email.strip)
  end

  validate :email_is_unique, if: "email.present?"

  validates :email,
    presence: true,
    format: { with: Account.email_regexp, allow_blank: true }

  validates :first_name,
    presence: true,
    length: { maximum: Person::NAME_MAX_LENGTH }
  validates :password,
    confirmation: true,
    presence: true,
    length: { within: Account.password_length, allow_blank: true }

  private

  # ActiveModel::Validations doesn't provide validates_uniqueness_of, so
  # we have to do it ourselves:
  def email_is_unique
    if Account.exists?(email: email.downcase) || Admin.exists?(email: email.downcase)
      errors.add(:email, :taken)
    end
  end

  def persist!
    @account = Account.new(
      email: email.strip,
      password: password,
      password_confirmation: password_confirmation,
    )
    account.save!(validate: false)

    person = account.people.build(first_name: first_name.strip)
    person.save!(validate: false)

    AccountMailer.notify_admin_of_sign_up(account.id).deliver_later
    IntercomJobs::CreateUser.perform_later(account_id: account.id)
  end

end
