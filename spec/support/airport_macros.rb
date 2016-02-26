module AirportMacros
  def create_airport(name, code, parent=nil)
    create(:airport, name: name, code: code, parent: parent)
  end
end
