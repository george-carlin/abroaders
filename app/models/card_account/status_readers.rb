module CardAccount::StatusReaders
  extend ActiveSupport::Concern

  included do
    CardAccount.statuses.keys.each do |status|
      define_method "#{status}?" do
        self.status == status
      end
    end
  end

end
