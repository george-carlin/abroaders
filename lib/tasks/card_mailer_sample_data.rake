namespace :ab do
  # Create the sample data that will be used by CardMailerPreview
  task card_mailer_sample_data: :environment do
    require Rails.root.join('spec/support/sample_data_macros').to_s
    include SampleDataMacros
    a = create_account email: 'card_mailer_test@example.com'
    3.times { create_card_account(person: a.owner) }
    a = create_account email: 'card_mailer_test_couples@example.com'
    create_companion(account: a)
    3.times { create_card_account(person: a.owner) }
    3.times { create_card_account(person: a.companion) }
  end
end
