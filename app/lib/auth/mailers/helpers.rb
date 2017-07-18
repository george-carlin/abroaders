module Auth
  module Mailers
    # DEVISETODO why is this a separate file? Why not just put the code
    # directly in Auth::Mailer?
    module Helpers
      extend ActiveSupport::Concern

      included do
        attr_reader :scope_name, :resource
      end

      protected

      # Configure default email options
      def devise_mail(record, action, opts = {})
        initialize_from_record(record)
        mail headers_for(action, opts)
      end

      def initialize_from_record(record)
        @scope_name = record.warden_scope
        name = record.model_name.singular.to_sym
        @resource = instance_variable_set("@#{name}", record)
      end

      def headers_for(action, opts)
        headers = {
          subject: subject_for(action),
          to: resource.email,
          from: mailer_sender(:from),
          reply_to: mailer_sender(:reply_to),
          template_path: template_paths,
          template_name: action,
        }.merge(opts)

        @email = headers[:to]
        headers
      end

      def mailer_sender(sender)
        default_sender = default_params[sender]
        if default_sender.present?
          default_sender.respond_to?(:to_proc) ? instance_eval(&default_sender) : default_sender
        else
          ENV['OUTBOUND_EMAIL_ADDRESS']
        end
      end

      def template_paths
        template_path = _prefixes.dup
        template_path.unshift "#{@resource.model_name.singular}/mailer"
        template_path
      end

      # Set up a subject doing an I18n lookup. At first, it attempts to set a subject
      # based on the current mapping:
      #
      #   en:
      #     devise:
      #       mailer:
      #         confirmation_instructions:
      #           user_subject: '...'
      #
      # If one does not exist, it fallbacks to ActionMailer default:
      #
      #   en:
      #     devise:
      #       mailer:
      #         confirmation_instructions:
      #           subject: '...'
      #
      def subject_for(key)
        I18n.t(:"#{@resource.model_name.singular}_subject", scope: [:devise, :mailer, key],
          default: [:subject, key.to_s.humanize],)
      end
    end
  end
end
