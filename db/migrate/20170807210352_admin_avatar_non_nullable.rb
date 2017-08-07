class AdminAvatarNonNullable < ActiveRecord::Migration[5.0]
  def change
    change_column_null :admins, :avatar_file_name, false
    change_column_null :admins, :avatar_content_type, false
    change_column_null :admins, :avatar_file_size, false
    change_column_null :admins, :avatar_updated_at, false
  end
end
