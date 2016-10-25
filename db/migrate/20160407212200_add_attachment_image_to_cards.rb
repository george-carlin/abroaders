class AddAttachmentImageToCards < ActiveRecord::Migration

  class Card < ActiveRecord::Base
    self.inheritance_column = :_no_sti

    ASPECT_RATIO = 1.586

    has_attached_file :image, styles: {
      large:  "350x#{350 / ASPECT_RATIO}>",
      medium: "210x#{210 / ASPECT_RATIO}>",
      small:  "140x#{140 / ASPECT_RATIO}>",
    }

    validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

    # So that paperclip will save images in the correct directory:
    def self.name
      "Card"
    end
  end

  def up
    ApplicationRecord.transaction do
      change_table :cards do |t|
        t.attachment :image
      end

      Card.reset_column_information

      dir = Rails.root.join("app", "assets", "images", "cards")

      Card.find_each do |card|
        card.update_attributes!(
          image: File.open(dir.join(card.image_name)),
        )
      end

      remove_column :cards, :image_name, :string

      change_column :cards, :image_file_name,    :string,   null: false
      change_column :cards, :image_content_type, :string,   null: false
      change_column :cards, :image_file_size,    :integer,  null: false
      change_column :cards, :image_updated_at,   :datetime, null: false
    end
  end

  def down
    # Note: this will make you lose all the image data! Be careful. Also
    # it's not an exact reverse as image_name was non-nullable before the 'up'
    # migration, but it'll be nullable if you migrate then rollback
    remove_attachment :cards, :image
    add_column :cards, :image_name, :string
  end
end
