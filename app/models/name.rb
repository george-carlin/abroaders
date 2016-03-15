# Object to be used in views to display things like 'you/your' or
# 'Steve/Steve's"
class Name

  def self.you
    new("you")
  end

  attr_reader :name, :possesive, :has, :is, :doesnt_have, :isnt, :was, :he_she

  def initialize(name)
    if name == "you"
      @name        = "you"
      @possesive   = "your"
      @doesnt_have = "don't have"
      @has         = "have"
      @he_she      = "you"
      @is          = "are"
      @isnt        = "aren't"
      @was         = "were"
    else
      @name        = name
      @possesive   = name + "'s"
      @doesnt_have = "doesn't have"
      @has         = "has"
      @he_she      = "he/she"
      @is          = "is"
      @isnt        = "isn't"
      @was         = "was"
    end
  end

end
