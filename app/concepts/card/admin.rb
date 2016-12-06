module Card::Admin
  # Hack to prevent annoying autoload error. See Rails issue #14844
  autoload :Contract, 'card/admin/contract'
end
