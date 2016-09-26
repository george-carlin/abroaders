require "rails_helper"

describe ApplicationHelper do
  describe "#name" do
    let(:account_with_companion) { create(:account, :with_companion) }
    let(:account_without_companion) { create(:account) }
    let(:person) { account_with_companion.owner }
    let(:name) { person.first_name }

    example "renaming account_with_companion" do
      expect(n("You have 2 cards", person)).to eq("#{name} has 2 cards")
      expect(n("How do you want to earn points?", person)).to eq("How does #{name} want to earn points?")
      expect(n("Are you eligible to apply?", person)).to eq("Is #{name} eligible to apply?")
      expect(n("What is your average monthly spending", person)).to eq("What is #{name}'s average monthly spending")
      expect(n("You aren't ready to apply", person)).to eq("#{name} isn't ready to apply")
      expect(n("If you're able to", person)).to eq("If #{name} is able to")
      expect(n("You don't have a card", person)).to eq("#{name} doesn't have a card")
      expect(n("Were you able to", person)).to eq("Was #{name} able to")
      expect(n("You don't have", person)).to eq("#{name} doesn't have")
      expect(n("Do you have", person)).to eq("Does #{name} have")
    end

    example "renaming account_with_companion with optional" do
      expect(n("You have 2 cards", person, true)).to eq("He/she has 2 cards")
      expect(n("How do you want to earn points?", person, true)).to eq("How does he/she want to earn points?")
      expect(n("Are you eligible to apply?", person, true)).to eq("Is he/she eligible to apply?")
      expect(n("What is your average monthly spending", person, true)).to eq("What is his/her average monthly spending")
      expect(n("This is yours", person, true)).to eq("This is his/hers")
      expect(n("You aren't ready to apply", person, true)).to eq("He/she isn't ready to apply")
      expect(n("If you're able to", person, true)).to eq("If he/she is able to")
      expect(n("You don't have a card", person, true)).to eq("He/she doesn't have a card")
      expect(n("you don't have a card", person, true)).to eq("he/she doesn't have a card")
      expect(n("Were you able to", person, true)).to eq("Was he/she able to")
      expect(n("You don't have", person, true)).to eq("He/she doesn't have")
      expect(n("Do you have", person, true)).to eq("Does he/she have")
    end

    example "renaming account_without_companion" do
      person = account_without_companion.owner
      expect(n("You have 2 cards", person)).to eq("You have 2 cards")
      expect(n("How do you want to earn points?", person)).to eq("How do you want to earn points?")
      expect(n("Are you eligible to apply?", person)).to eq("Are you eligible to apply?")
      expect(n("What is your average monthly spending", person)).to eq("What is your average monthly spending")
      expect(n("You aren't ready to apply", person)).to eq("You aren't ready to apply")
      expect(n("If you're able to", person)).to eq("If you're able to")
      expect(n("You don't have a card", person)).to eq("You don't have a card")
      expect(n("Were you able to", person)).to eq("Were you able to")
      expect(n("You don't have", person)).to eq("You don't have")
    end

    example "case sensitive" do
      expect(n("You have 2 cards", person)).to eq("#{name} has 2 cards")
      expect(n("you have 2 cards", person)).to eq("#{name} has 2 cards")
      expect(n("Are you eligible to apply?", person)).to eq("Is #{name} eligible to apply?")
      expect(n("are you eligible to apply?", person)).to eq("is #{name} eligible to apply?")
      expect(n("Were you able to", person)).to eq("Was #{name} able to")
      expect(n("were you able to", person)).to eq("was #{name} able to")
    end
  end
end
