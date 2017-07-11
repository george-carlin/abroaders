# Validate that an account can't use an email address that's already being
# used by another Account, *or* by an Admin.
#
# There's no actual DB constraint to enforce this, it's only happening at the
# application layer. Ideally we should add a DB constraint as well but I don't
# know to validate that an entry is unique across two columns in two separate
# tables?
#
# Example usage:
#
#     class SignUpForm < Reform::Form
#       validation do
#         validate(&Account::ValidateEmailUniqueness)
#       end
#     end
#
Account::ValidateEmailUniqueness = proc do
  # self will be the instance of Account
  next unless email.present?
  addr = email.downcase
  # This 'not' statement is necessary, otherwise updating an account without
  # changing its email address, it will fail because exists? returns itself.
  if Account.where.not(id: id).exists?(email: addr) || Admin.exists?(email: addr)
    errors.add(:email, :taken)
  end
end
