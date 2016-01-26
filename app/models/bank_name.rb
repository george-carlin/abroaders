class BankName
  attr_reader :id

  def initialize(id)
    @id = id.to_s
  end

  def name
    @name ||= id.gsub(/_/, " ").split.map do |word|
      word == "us" ? "US" : word.capitalize
    end.join(" ")
  end

end
