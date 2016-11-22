class Account::Cell < Trailblazer::Cell
  # Hack to prevent annoying autoload error. See Rails issue #14844
  autoload :Admin, 'account/cell/admin'
end
