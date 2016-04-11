# Object to be used in views to display things like 'you/your' or
# 'Steve/Steve's"
#
# TODO can this be deleted?
class Name

  def self.you
    new("you")
  end

  attr_reader :name, :possessive, :has, :is, :doesnt_have, :isnt, :was, :he_she,
    :does

  def initialize(name)
    if name == "you"
      @name        = "you"
      @possessive  = "your"
      @does        = "do"
      @doesnt_have = "don't have"
      @has         = "have"
      @he_she      = "you"
      @is          = "are"
      @isnt        = "aren't"
      @was         = "were"
    else
      @name        = name
      @possessive  = name + "'s"
      @does        = "does"
      @doesnt_have = "doesn't have"
      @has         = "has"
      @he_she      = "he/she"
      @is          = "is"
      @isnt        = "isn't"
      @was         = "was"
    end
  end

  def he_she_isnt
    if name == "you"
      "you're not"
    else
      "he/she isn't"
    end
  end

end
