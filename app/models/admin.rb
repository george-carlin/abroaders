class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # stubs for using admin as the inviter
  def has_invitations_left?
    true
  end

  def decrement_invitation_limit!; end
end
