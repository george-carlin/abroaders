### Background Jobs

- Look at the 'worker' task in the `Procfile` to see the command that processes
  background jobs. You probably also need to set the `QUEUE` env variable (if
  in doubt, set it to `*`).

- Background jobs are queued using Resque, which uses `Redis` to store data
  about each job. Redis is just a simple key-value datastore, which means
  that **it can only store basic datatypes like numbers and strings**.

  So the following code won't work:

      widget = Widget.find(1)
      UpdateWidget.perform_later(widget)

      # within app/jobs/update_widget.rb:
      def perform(widget)
        widget.update!
      end

  ... because instances of 'Widget' can't be stored in Redis. You can fix
  this by passing in the ID instead:

      UpdateWidget.perform_later(1)

      # app/jobs/update_widget.rb:
      def perform(widget_id)
        widget = Widget.find(widget_id)
        widget.update!
      end

- Similarly, **use strings, not symbols, as option keys** - otherwise
  you'll break Redis:

        # bad
        def perform(opts = {})
          do_something_with(opts.fetch(:my_key))
        end

        # good
        def perform(opts = {})
          do_something_with(opts.fetch('my_key'))
        end

  A corollary here is that **background jobs can't use Ruby keyword arguments**.

        # this won't work
        def perform(my_key:)
          do_something_with(my_key)
        end


- Remember that you don't know in advance when a background job will be
  performed, so there's no guarantee that (e.g.) the database will still be in
  the same state when the job is performed that it was when the job was
  enqueued. So, for example, code like this is risky:

      card_account.update_attributes!(something)
      NotifyAdminOfUpdate.perform_later(card_account.id)

      # app/jobs/notify_admin_of_update.rb:
      def perform(card_account_id)
        ca = CardAccount.find(card_account_id)
        Admin.notify("Card Account ##{ca.id} was updated at #{ca.updated_at}")
      end

  The problem is that the card account may have been updated *again* since you
  queued the job, so the admin will get a notification with the more recent
  timestamp, which probably isn't what you intended.

  When it's important that the background job uses *current* data, pass the
  data in directly instead of relying on pulling it out of the DB later:

      card_account.update_attributes!(something)
      NotifyAdminOfUpdate.perform_later(card_account.id, card_account.updated_at)

      # app/jobs/notify_admin_of_update.rb:
      def perform(card_account_id, updated_at)
        Admin.notify("Card Account ##{card_account_id} was updated at #{updated_at}")
      end

