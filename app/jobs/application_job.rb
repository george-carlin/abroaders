class ApplicationJob < ActiveJob::Base
  before_perform do |job|
    # for some reason when I call Job.perform_now in the console, I get some
    # logging output from AJ directly, but when I run the jobs in the resque
    # rake task, I don't see the same output. So use this code to output some
    # custom logging.
    if ENV['LOG_PERFORMED_JOBS']
      puts "performing #{job.class} on queue :#{job.queue_name}, "\
           "id #{job.job_id}, args #{job.arguments.inspect}"
    end
  end
end
