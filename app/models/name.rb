# Object to be used in views to display things like 'you/your' or
# 'Steve/Steve's"
class Name
  def self.you
    new("you")
  end

  attr_reader :name, :possessive, :has, :is, :doesnt_have, :isnt, :was, :he_she,
              :does, :doesnt, :him_her, :his_hers, :i_am, :i

  def initialize(name)
    if name == "you"
      @name        = "you"
      @possessive  = "your"
      @does        = "do"
      @doesnt      = "do not"
      @doesnt_have = "don't have"
      @has         = "have"
      @he_she      = "you"
      @is          = "are"
      @isnt        = "aren't"
      @was         = "were"
      @him_her     = "you"
      @his_hers    = "your"
      @i_am        = "I'm"
      @i           = "I"
    else
      @name        = name
      @possessive  = name + "'s"
      @does        = "does"
      @doesnt      = "does not"
      @doesnt_have = "doesn't have"
      @has         = "has"
      @he_she      = "he/she"
      @is          = "is"
      @isnt        = "isn't"
      @was         = "was"
      @him_her     = "him/her"
      @his_hers    = "his/hers"
      @i_am        = "he/she is"
      @i           = "he/she"
    end
  end
end
