class Recommendation::Cell < Trailblazer::Cell
  # Hack to prevent annoying autoload error. See Rails issue #14844
  autoload :Admin, 'recommendation/cell/admin'
  autoload :Note,  'recommendation/cell/note'
end
