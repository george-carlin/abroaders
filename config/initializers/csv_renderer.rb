# see http://api.rubyonrails.org/classes/ActionController/Renderers.html#method-c-add
ActionController::Renderers.add :csv do |str, options|
  filename = options[:filename] || 'data'
  send_data str, type: Mime[:csv],
    disposition: "attachment; filename=#{filename}.csv"
end
