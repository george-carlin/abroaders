class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # Use this to fake a 'belongs_to' relationship between an ApplicationRecord
  # model and a FakeDBModel (see the comments in app/model/fake_db_model.rb for
  # more info)
  def self.belongs_to_fake_db_model(association_name)
    assoc_class     = association_name.to_s.classify.constantize
    assoc_fk_col    = "#{association_name.to_s}_id"
    assoc_fk_setter = "#{assoc_fk_col}="
    memoized_ivar   = "@#{association_name}"

    #   belongs_to_fake_db_model :alliance

    #   def alliance
    #     @alliance ||= Alliance.find(alliance_id) if alliance_id.present?
    #   end
    define_method association_name do
      assoc_fk = self.send(assoc_fk_col)
      instance_variable_set(
        memoized_ivar,
        assoc_class.find(assoc_fk)
      ) if assoc_fk.present?
    end

    #   def alliance=(new_alliance)
    #     # raise error if new_alliance is not an Alliance
    #     self.alliance_id = new_alliance.id
    #   end
    define_method "#{association_name}=" do |new_item|
      # c/f active_record/associations/association.rb:
      unless new_item.class == assoc_class
        message = "#{assoc_class.name}(##{assoc_class.object_id}) expected, "\
                  "got #{new_item.class.name}(##{new_item.class.object_id})"
        raise ActiveRecord::AssociationTypeMismatch, message
      end
      self.send(assoc_fk_setter, new_item.id)
    end

    #   def alliance_id=(alliance_id)
    #     @alliance = nil
    #     super
    #   end
    define_method assoc_fk_setter do |new_fk|
      instance_variable_set(memoized_ivar, nil)
      super(new_fk)
    end
  end
end
