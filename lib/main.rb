module Main
  # Hack to prevent annoying autoload error. See Rails issue #14844
  autoload :Cells, 'main/cells'
  autoload :Presenters, 'main/presenters'
end
