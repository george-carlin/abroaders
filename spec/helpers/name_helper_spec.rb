require "rails_helper"

RSpec.describe NameHelper, type: :helper do
  describe '#name_conjugation' do
    let(:couples_account) { create(:couples_account) }
    let(:solo_account)    { create(:account) }
    let(:person)          { couples_account.owner }
    let(:name)            { person.first_name }

    example "renaming couples_account" do
      expect(n("You have 2 cards", person)).to eq("#{name} has 2 cards")
      expect(n("How do you want to earn points?", person)).to eq("How does #{name} want to earn points?")
      expect(n("Are you eligible to apply?", person)).to eq("Is #{name} eligible to apply?")
      expect(n("What is your average monthly spending", person)).to eq("What is #{name}'s average monthly spending")
      expect(n("If you're able to", person)).to eq("If #{name} is able to")
      expect(n("You don't have a card", person)).to eq("#{name} doesn't have a card")
      expect(n("Were you able to", person)).to eq("Was #{name} able to")
      expect(n("Do you have", person)).to eq("Does #{name} have")
      expect(n("We will tell you", person)).to eq("We will tell #{name}")
      expect(n("How are you?", person)).to eq("How is #{name}?")
    end

    example "renaming couples_account with optional" do
      expect(n("You have 2 cards", person, true)).to eq("He/she has 2 cards")
      expect(n("How do you want to earn points?", person, true)).to eq("How does he/she want to earn points?")
      expect(n("Are you eligible to apply?", person, true)).to eq("Is he/she eligible to apply?")
      expect(n("What is your average monthly spending", person, true)).to eq("What is his/her average monthly spending")
      expect(n("This is yours", person, true)).to eq("This is his/hers")
      expect(n("If you're able to", person, true)).to eq("If he/she is able to")
      expect(n("You don't have a card", person, true)).to eq("He/she doesn't have a card")
      expect(n("Were you able to", person, true)).to eq("Was he/she able to")
      expect(n("Do you have", person, true)).to eq("Does he/she have")
      expect(n("How are you?", person, true)).to eq("How is he/she?")

      # TODO: correct expected result is "We will tell him/her"
      expect(n("We will tell you", person, true)).to eq("We will tell he/she")
    end

    example "renaming solo_account" do
      person = solo_account.owner
      expect(n("You have 2 cards", person)).to eq("You have 2 cards")
      expect(n("How do you want to earn points?", person)).to eq("How do you want to earn points?")
      expect(n("Are you eligible to apply?", person)).to eq("Are you eligible to apply?")
      expect(n("What is your average monthly spending", person)).to eq("What is your average monthly spending")
      expect(n("If you're able to", person)).to eq("If you're able to")
      expect(n("You don't have a card", person)).to eq("You don't have a card")
      expect(n("Were you able to", person)).to eq("Were you able to")
      expect(n("We will tell you", person)).to eq("We will tell you")
      expect(n("How are you?", person)).to eq("How are you?")
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
