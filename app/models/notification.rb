class Notification < ApplicationRecord

  # Associations

  belongs_to :account

  # Scopes

  scope :seen,   -> { where(seen: true) }
  scope :unseen, -> { where(seen: false) }

  # Callbacks

  after_create  { account.increment_unseen_notifications_count }
  after_destroy { account.decrement_unseen_notifications_count }

end
