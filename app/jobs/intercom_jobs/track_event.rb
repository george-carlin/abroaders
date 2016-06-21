module IntercomJobs
  class TrackEvent < ApplicationJob
    queue_as :intercom

    def perform(opts={})
      opts.symbolize_keys!
      opts[:created_at] = opts[:created_at].to_i

      INTERCOM.events.create(opts)
    end

    %i[later now].each do |time|
      define_method "perform_#{time}" do |opts={}|
        opts.symbolize_keys!
        opts[:created_at] ||= Time.now.to_i
        super(opts)
      end
    end

  end
end
