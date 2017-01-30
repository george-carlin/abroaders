task stats: "ab:stat_setup"

# Include custom directories (such as forms) when running rake stats
namespace :ab do
  task :stat_setup do
    [
      ["Forms",       "app/forms"],
      ["Presenters",  "app/presenters"],
      ["Serializers", "app/serializers"],
    ].each do |name, dir|
      ::STATS_DIRECTORIES << [name, Rails.root.join(dir)]
      ::CodeStatistics::TEST_TYPES << name if dir =~ /\Aspec\//
    end
  end
end
