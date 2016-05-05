class SignUp < ApplicationForm
  include ActiveModel::Dirty

  attr_reader :account
  attr_accessor :email, :first_name, :password, :first_name

  define_attribute_methods :email

  def initialize(params={})
    @account    = Account.new
    self.email      = params[:email]
    self.first_name = params[:first_name]
    self.password   = params[:password]
    self.password_confirmation = params[:password_confirmation]
  end

  def save
    super do
      account.assign_attributes(
        email: email.strip,
        password: password,
        password_confirmation: password_confirmation,
      )
      account.save!(validate: false)

      person = account.people.build(first_name: first_name.strip)
      person.save!(validate: false)
    end
  end


  validate :email_is_unique, if: "email.present?"

  validates :email,
    presence: true,
    format: { with: Account.email_regexp, allow_blank: true, if: :email_changed? }

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

end

