class Region < Destination
  validates :parent, absence: true
end
