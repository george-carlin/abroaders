require "rails_helper"

describe "as a new user" do
  let(:account) { create(:account) }
  before { login_as account, scope: :account }
  subject { page }

  describe "the passengers survey" do
    before { visit survey_passengers_path }

    # Stop the lines from being so long!
    let(:ps_prefix) { :passenger_survey }
    let(:mp_prefix) { "#{ps_prefix}_main_passenger" }
    let(:co_prefix) { "#{ps_prefix}_companion" }

    let(:submit_form) { click_button "Save" }

    DEFAULT_PASSENGER_FIELDS = %i[
      first_name
      middle_names
      last_name
      phone_number
      whatsapp
      text_message
      imessage
      citizenship_us_citizen
      citizenship_us_permanent_resident
      citizenship_neither
    ]

    def fill_in_valid_main_passenger
      fill_in "#{mp_prefix}_first_name",   with: "Fred"
      fill_in "#{mp_prefix}_middle_names", with: "James"
      fill_in "#{mp_prefix}_last_name",    with: "Bloggs"
      fill_in "#{mp_prefix}_phone_number", with: "0123412341"
      select "(GMT+00:00) London", from: "#{ps_prefix}_time_zone"
      choose "#{mp_prefix}_citizenship_us_permanent_resident"
      check  "#{mp_prefix}_text_message"
      check  "#{mp_prefix}_imessage"
      check  "#{mp_prefix}_whatsapp"
    end

    JQUERY_DEFAULT_SLIDE_DURATION = 0.4
    # Some elements on the page are hidden/shown using jQuery's 'slide' methods,
    # which by default take 400ms to complete. So use this method to wait
    # for a slideUp/slideDown to finish:
    def wait_for_slide
      sleep JQUERY_DEFAULT_SLIDE_DURATION
    end

    it "has inputs for the main passenger's attributes" do
      DEFAULT_PASSENGER_FIELDS.each do |field|
        is_expected.to have_field "#{mp_prefix}_#{field}"
      end
    end

    describe "the 'time zone' dropdown" do
      it "has US time zones sorted to the top" do
        input_name = "passenger_survey[time_zone]"
        us_zones   = ActiveSupport::TimeZone.us_zones.map(&:name)
        options  = all("select[name='#{input_name}'] > option")
        expect(options.first(us_zones.length).map(&:value)).to \
          match_array(us_zones)
      end
    end

    it "doesn't have fields for a travel companion" do
      DEFAULT_PASSENGER_FIELDS.each do |field|
        is_expected.to have_no_field "#{co_prefix}_#{field}"
      end
    end

    it "has a checkbox asking if I have a travel companion" do
      is_expected.to have_field "#{ps_prefix}_has_companion"
    end

    it "doesn't ask if I or my companion are willing to apply for cards" do
      is_expected.to have_no_field "#{mp_prefix}_willing_to_apply_true"
      is_expected.to have_no_field "#{mp_prefix}_willing_to_apply_false"
      is_expected.to have_no_field "#{co_prefix}_willing_to_apply_true"
      is_expected.to have_no_field "#{co_prefix}_willing_to_apply_false"
    end

    describe "checking the 'I have a travel companion' checkbox", :js do
      before do
        check "#{ps_prefix}_has_companion"
        wait_for_slide
      end

      it "shows the fields for a travel companion" do
        DEFAULT_PASSENGER_FIELDS.each do |field|
          is_expected.to have_field "#{co_prefix}_#{field}"
        end
      end

      it "asks if my companion and I share expenses" do
        is_expected.to have_field "#{ps_prefix}_shares_expenses_true"
        is_expected.to have_field "#{ps_prefix}_shares_expenses_false"
      end

      it "asks if I am willing to apply for cards (default yes)" do
        is_expected.to have_field "#{mp_prefix}_willing_to_apply_true"
        is_expected.to have_field "#{mp_prefix}_willing_to_apply_false"
        yes = find("##{mp_prefix}_willing_to_apply_true")
        expect(yes[:checked]).to be_truthy
      end

      it "asks if my companion is willing to apply for cards (default yes)" do
        is_expected.to have_field "#{co_prefix}_willing_to_apply_true"
        is_expected.to have_field "#{co_prefix}_willing_to_apply_false"
        yes = find("##{co_prefix}_willing_to_apply_true")
        expect(yes[:checked]).to be_truthy
      end

      pending "unchecking the box hides everything and doesn't fuck up the form submit later"

      describe "saying that neither I nor my companion are willing to apply" do
        before do
          choose "#{mp_prefix}_willing_to_apply_false"
          choose "#{co_prefix}_willing_to_apply_false"
        end

        it "displays an error message" do
          is_expected.to have_selector "#unwilling_to_apply_err_msg"
        end

        let(:radio_btns) { all("input[name*=willing_to_apply]") }
        # Every input except the 'i am/am not willing to apply' radios:
        let(:other_inputs) do
          all("input:not([name*=willing_to_apply]), select, button")
        end

        it "disables every input except the 'willing' radios" do
          expect(other_inputs.all? { |i| i[:disabled] }).to be_truthy
          expect(radio_btns.none?  { |i| i[:disabled] }).to be_truthy
        end

        describe "and undoing" do
          before { choose "#{mp_prefix}_willing_to_apply_true" }
          it "hides the error message" do
            is_expected.to have_no_selector "#unwilling_to_apply_err_msg"
          end

          it "reenables the form" do
            expect(other_inputs.none? { |i| i[:disabled] }).to be_truthy
            expect(radio_btns.none?   { |i| i[:disabled] }).to be_truthy
          end
        end
      end # saying that neither I nor my companion are willing to apply

      describe "and submitting the form" do
        describe "with valid information about both passengers" do
          before do
            fill_in_valid_main_passenger
            fill_in "#{co_prefix}_first_name",   with: "Steve"
            fill_in "#{co_prefix}_middle_names", with: "Peter"
            fill_in "#{co_prefix}_last_name",    with: "Jones"
            fill_in "#{co_prefix}_phone_number", with: "091827364650"
            choose "#{co_prefix}_citizenship_neither"
            check  "#{co_prefix}_text_message"
            check  "#{co_prefix}_imessage"
            check  "#{co_prefix}_whatsapp"
            choose "#{ps_prefix}_shares_expenses_true"
          end

          it "saves information about my travel companion and I" do
            expect{submit_form}.to change{account.passengers.count}.by(2)

            account.reload
            expect(account.time_zone).to eq "London"
            expect(account.shares_expenses).to be_truthy

            mp = account.main_passenger
            expect(mp).to be_persisted
            expect(mp.first_name).to eq   "Fred"
            expect(mp.middle_names).to eq "James"
            expect(mp.last_name).to eq    "Bloggs"
            expect(mp.phone_number).to eq "0123412341"
            expect(mp.citizenship).to eq  "us_permanent_resident"
            expect(mp.text_message).to be_truthy
            expect(mp.imessage).to be_truthy
            expect(mp.whatsapp).to be_truthy
            expect(mp.willing_to_apply).to be_truthy

            co = account.companion
            expect(co).to be_persisted
            expect(co.first_name).to eq   "Steve"
            expect(co.middle_names).to eq "Peter"
            expect(co.last_name).to eq    "Jones"
            expect(co.phone_number).to eq "091827364650"
            expect(co.citizenship).to eq  "neither"
            expect(co.text_message).to be_truthy
            expect(co.imessage).to be_truthy
            expect(co.whatsapp).to be_truthy
            expect(co.willing_to_apply).to be_truthy
          end

          it "marks my 'onboarding stage' as 'spending'" do
            submit_form
            expect(account.reload.onboarding_stage).to eq "spending"
          end

          it "takes me to the spending survey page" do
            submit_form
            expect(current_path).to eq survey_spending_path
          end
        end

        describe "with invalid information" do
          it "doesn't save information about me or my travel companion" do
            # The test fails on Codeship unless you reload account first
            # (something to do with millisecond/second precision in the
            # timestamps on Codeship's env)
            account.reload
            updated_at_before = account.updated_at
            expect{submit_form}.not_to change{Passenger.count}
            expect(account.reload.updated_at).to eq updated_at_before
          end

          it "doesn't change my 'onboarding stage'" do
            submit_form
            expect(account.reload.onboarding_stage).to eq "passengers"
          end

          it "shows the form again with an error message" do
            submit_form
            expect(current_path).to eq survey_passengers_path
            expect(page).to have_error_message
          end
        end
      end
    end # checking the 'I have a travel companion' checkbox

    describe "submitting the form" do
      context "with valid information about myself" do
        before { fill_in_valid_main_passenger }

        it "saves my information" do
          expect(account.main_passenger).not_to be_persisted
          expect{submit_form}.to change{account.passengers.count}.by(1)
          account.reload
          expect(account.time_zone).to eq "London"
          me = account.main_passenger
          expect(me).to be_persisted
          expect(me.first_name).to eq "Fred"
          expect(me.middle_names).to eq "James"
          expect(me.last_name).to eq "Bloggs"
          expect(me.phone_number).to eq "0123412341"
          expect(me.citizenship).to eq "us_permanent_resident"
        end

        it "saves that I am willing to apply for cards" do
          # Note it doesn't actually ask me this question unless I also add a
          # travel companion (in which case it asks for both of us)
          submit_form
          expect(account.reload.main_passenger).to be_willing_to_apply
        end

        it "marks my 'onboarding stage' as 'spending'" do
          submit_form
          expect(account.reload.onboarding_stage).to eq "spending"
        end

        it "takes me to the spending survey page" do
          submit_form
          expect(current_path).to eq survey_spending_path
        end
      end

      context "with invalid information" do
        it "doesn't save my information" do
          expect{submit_form}.not_to change{Passenger.count}
        end

        it "doesn't change my 'onboarding stage'" do
          submit_form
          expect(account.reload.onboarding_stage).to eq "passengers"
        end

        it "shows the form again with an error message" do
          submit_form
          expect(current_path).to eq survey_passengers_path
          expect(page).to have_error_message
        end
      end
    end # submitting the form
  end
end
