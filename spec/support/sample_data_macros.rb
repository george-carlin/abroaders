require 'abroaders/util'

module SampleDataMacros
  def sample_json(file_name)
    File.read(SPEC_ROOT.join('support', 'sample_data', "#{file_name}.json"))
  end

  def parsed_sample_json(file_name, underscore_keys: true)
    hash = JSON.parse(get_sample_json(file_name))
    if underscore_keys
      Abroaders::Util.underscore_keys(hash)
    else
      hash
    end
  end
end
