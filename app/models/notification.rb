class Notification < ApplicationRecord

  def unseen?
    !seen?
  end

  # Associations

  belongs_to :account

  # Scopes

  scope :seen,   -> { where(seen: true) }
  scope :unseen, -> { where(seen: false) }

  # Callbacks

  after_create  { account.increment_unseen_notifications_count if unseen? }
  after_destroy { account.decrement_unseen_notifications_count if unseen? }
  after_update :update_account_unseen_notifications_count

  private

  def update_account_unseen_notifications_count
    if seen_changed?
      account.send("#{seen ? "de" : "in"}crement_unseen_notifications_count")
    end
  end

end
