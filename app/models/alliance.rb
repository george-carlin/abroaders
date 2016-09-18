class Alliance < FakeDBModel
  attribute :name, String

  TABLE = [
      # columns: id name
      [1, "OneWorld"],
      [2, "StarAlliance"],
      [3, "SkyTeam"]
  ]

  def self.order(column="name")
    column = column.to_s.downcase
    unless column.include?("name")
      raise "Alliance.order can currently only order alliances by name"
    end
    if column.include?("desc")
      all.sort_by(&:name).reverse
    else
      all.sort_by(&:name)
    end
  end

  def self.find_by(query)
    query.symbolize_keys!

    if query.key?(:id)
      if row = TABLE.find { |r| r[0] == query[:id] }
        id, name= *row
        new(id: id, name: name)
      else
        raise ActiveRecord::RecordNotFound, "Couldn't find #{self} with 'id'=#{query[:id]}"
      end
    elsif query.key?(:name)
      if row = TABLE.find { |r| r[1] == query[:name] }
        id, name = *row
        new(id: id, name: name)
      else
        raise ActiveRecord::RecordNotFound, "Couldn't find #{self} with 'name'=#{query[:name]}"
      end
    else
      raise "Alliance.find_by can currently only look up currencies by name or id"
    end
  end

  def self.find_by_name(name)
    find_by(name: name)
  end

  def currencies
    Currency.where(alliance_id: id)
  end
end
