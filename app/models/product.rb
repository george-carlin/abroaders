class Product
  # Hack to prevent annoying autoload error. See Rails issue #14844
  autoload :Cell, 'product/cell'
end
