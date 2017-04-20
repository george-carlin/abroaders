require 'rails_helper'

RSpec.describe CardRecommendation::Validate do
  def test_attributes(attrs)
    rec = Card.new(attrs)
    described_class.(rec)
  end

  specify 'recommended_at must be present' do
    expect(test_attributes({})).to be false
  end

  let(:time) { Time.now }

  specify 'only one of declined, applied and expired may be present at once' do
    timestamps = %w[applied_on expired_at]
    timestamps.each do |timestamp|
      attrs = { recommended_at: time, timestamp => time }
      expect(test_attributes(attrs)).to be true
      other_timestamp = (timestamps - [timestamp]).sample
      attrs[other_timestamp] = time
      expect(test_attributes(attrs)).to be false
    end

    # test declined_at outside of the above loop because the extra requirement
    # for decline_reason to be present messes up those tests:
    timestamps.each do |timestamp|
      attrs = { recommended_at: time, declined_at: time, decline_reason: 'X' }
      attrs[timestamp] = time
      expect(test_attributes(attrs)).to be false
    end
  end

  specify 'decline_reason is present iff declined_at is present' do
    attrs = { recommended_at: time }
    attrs[:declined_at] = time # timestamp, no reason
    expect(test_attributes(attrs)).to be false
    attrs[:decline_reason] = 'X' # both timestamp and reason
    expect(test_attributes(attrs)).to be true
    attrs[:declined_at] = nil # reason, no timestamp
    expect(test_attributes(attrs)).to be false
  end

  # The above examples test the attributes that are relevant to the
  # 'recommendation' stage. The below examples test the attributes that are
  # relevant to the 'application' stage. Eventually I hope to represent card
  # recs and card apps with completely separate models, but for now the
  # validations will have to live in one place.

  let(:applied_attrs) { { recommended_at: time, applied_on: time } }

  example "can't be opened unless applied" do
    attrs = applied_attrs.merge(opened_on: time)
    expect(test_attributes(attrs)).to be true
    attrs[:applied_on] = nil
    expect(test_attributes(attrs)).to be false
  end

  example "can't be denied unless applied" do
    attrs = applied_attrs.merge(denied_at: time)
    expect(test_attributes(attrs)).to be true
    attrs[:applied_on] = nil
    expect(test_attributes(attrs)).to be false
  end

  example "can't nudge unless applied" do
    attrs = applied_attrs.merge(nudged_at: time)
    expect(test_attributes(attrs)).to be true
    attrs[:applied_on] = nil
    expect(test_attributes(attrs)).to be false
  end

  example "can't call unless denied" do
    attrs = applied_attrs.merge(called_at: time, denied_at: time)
    expect(test_attributes(attrs)).to be true
    attrs[:denied_at] = nil
    expect(test_attributes(attrs)).to be false
  end

  example "can't be redenied unless called" do
    attrs = applied_attrs.merge(denied_at: time, called_at: time, redenied_at: time)
    expect(test_attributes(attrs)).to be true
    attrs[:called_at] = nil
    expect(test_attributes(attrs)).to be false
  end

  example "can't be opened if redenied" do
    attrs = applied_attrs.merge(denied_at: time, called_at: time, redenied_at: time)
    expect(test_attributes(attrs)).to be true
    attrs[:opened_on] = time
    expect(test_attributes(attrs)).to be false
  end

  example "can't be opened if nudged and denied" do
    attrs = applied_attrs.merge(nudged_at: time, denied_at: time)
    expect(test_attributes(attrs)).to be true
    attrs[:opened_on] = time
    expect(test_attributes(attrs)).to be false
  end

  example "can't be both nudged and called" do
    attrs = applied_attrs.merge(nudged_at: time, called_at: time)
    expect(test_attributes(attrs)).to be false
  end

  example "can't be both nudged and redenied" do
    attrs = applied_attrs.merge(nudged_at: time, redenied_at: time)
    expect(test_attributes(attrs)).to be false
  end
end
