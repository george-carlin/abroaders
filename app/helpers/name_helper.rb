module NameHelper
  # If current_account.couples? is false, then the string will be returned unchanged.
  # If it's true, then any instances of "you", "you're", etc will be replaced with the person's name,
  # and verbs will be changed into the 3rd-person conjugation.
  #
  # ex:
  # n("You have 2 cards", @person) => "George has 2 cards"
  #
  # When the account has no companion (returns the string unchanged):
  # n("You have 2 cards", @person) => "You have 2 cards"
  #
  # How we use this: 'raw' text in the views is always written in the 2nd
  # person ("you have", "you are", "yours" etc). If we want to dynamically
  # change this to show the person's name when the account has a companion,
  # wrap the text in the view with `<%= n(.... , person) %>`. Optionally
  # pass `true` as the third argument to use 'he/she' instead of the person's
  # name.
  def name_conjugation(text, person, he_she = false)
    return text unless person.account.couples?

    person_name = person.first_name
    rules = {
      "are": ["is"],
      "aren't": ["isn't"],
      "do": ["does"],
      "don't": ["doesn't"],
      "have": ["has"],
      "haven't": ["hasn't"],
      "were": ["was"],
      "weren't": ["wasn't"],
      "you": [person_name, "he/she"],
      "you're": ["#{person_name} is", "he/she is"],
      "your": ["#{person_name}'s", "his/her"],
      "yours": ["#{person_name}'s", "his/hers"],
    }

    rules.each do |from, to|
      from = from.to_s

      # second iteration for capitalize expressions
      2.times do
        if text =~ /\b#{from}(?![\w\'\"])/

          # Prevent double third person verb
          # ex. from 'Do you have' we get 'Does you have', not 'Does you has'
          if from.casecmp("have") == 0
            next if text.downcase =~ /\b(does|doesn't)(?![\w\'\"])/
          end

          text = if he_she && to[1]
                   text.gsub(from, to[1])
                 else
                   text.gsub(from, to[0])
                 end
        end
        from = from.capitalize
        to[0] = to[0].capitalize
        to[1] = to[1].capitalize if to[1]
      end
    end

    text
  end
  alias n name_conjugation
end