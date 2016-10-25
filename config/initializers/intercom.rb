# rubocop:disable Style/MethodMissing
if ENV["INTERCOM_APP_ID"] && ENV["INTERCOM_API_KEY"]
  INTERCOM = Intercom::Client.new(app_id: ENV["INTERCOM_APP_ID"], api_key: ENV["INTERCOM_API_KEY"])
else
  class DummyIntercom
    class DoNothing
      def method_missing(meth, *args, &block)
      end
    end

    def method_missing(meth, *_args)
      warn "Intercom method `#{meth}` called but Intercom not set up. Make "\
           "sure the INTERCOM_APP_ID and INTERCOM_API_KEY environment "\
           "variables are set"

      DoNothing.new
    end
  end

  warn "Couldn't initialize Intercom. Make sure the INTERCOM_APP_ID and "\
       "INTERCOM_API_KEY environment variables are set."
  INTERCOM = DummyIntercom.new
end
