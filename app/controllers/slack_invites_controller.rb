# This is lifted from the 'slack-invite-automation' micro app at
# https://github.com/outsideris/slack-invite-automation/.
#
# That app is written in node.js, but because we're cheap, we wanted to be able
# to host it in the same Heroku repo as the main app. So rather than figure out
# how to make a Heroku dyno simultaneously respond to some requests via the
# Rails server and other requests via Express, I elected to just rewrite the
# express app in Ruby:
#
# Further references:
#   https://ruby.unicorn.tv/screencasts/automatically-send-slack-invitations
#   https://levels.io/slack-typeform-auto-invite-sign-ups/
#
class SlackInvitesController < ApplicationController
  layout "slack_invites"
  skip_before_action :verify_authenticity_token

  def new
    @community = "Abroaders Community"
  end

  def create
    uri = URI.parse("https://#{ENV['SLACK_URL']}/api/users.admin.invite")

    slack_raw_response = Net::HTTP.post_form(
      uri,
      email: params[:email],
      token: ENV["SLACK_TOKEN"],
      set_active: true,
      _attempts: 1,
    )
    slack_response = JSON.parse(slack_raw_response.body)

    # response body looks like:
    #   {"ok":true}
    #       or
    #   {"ok":false,"error":"already_invited"}
    puts slack_response.to_s
    if slack_response["ok"]
      @message = "Success! Check #{params[:email]} for an invite from Slack."
    else
      error = slack_response["error"]
      if %w[already_invited already_in_team].include?(error)
        @message = "Success! You were already invited.<br>"\
                   "Visit the <a href='https://#{ENV['SLACK_URL']}'>Abroaders"\
                   " community</a>"
      elsif error == 'invalid_email'
        @failed  = true
        @message = 'Failed! The email you entered is an invalid email.'
      elsif error == 'invalid_auth'
        @failed  = true
        @message = "Failed! Something has gone wrong. Please contact a "\
                   "system administrator."
      else
        raise error.to_s
      end
    end

    render 'result'
  end
end
