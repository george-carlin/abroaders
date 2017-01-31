module IntercomJobs
  class Base < ApplicationJob
    class << self
      %w[perform_later perform_now].each do |meth|
        define_method meth do |*args|
          if ENV['DISABLE_INTERCOM']
            Rails.logger.info("not performing #{self} - Intercom jobs are disabled")
            return
          end

          super(*args)
        end
      end
    end
  end
end
