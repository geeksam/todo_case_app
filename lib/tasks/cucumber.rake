namespace :features do
  begin
    require 'cucumber'
    require 'cucumber/rake/task'

    Cucumber::Rake::Task.new(:ok) do |t|
      t.profile = "ok"
    end

    Cucumber::Rake::Task.new(:wip) do |t|
      t.profile = "wip"
    end
  rescue LoadError
    desc 'Cucumber rake task not available'
    task :ok do
      abort 'Cucumber rake task is not available. Be sure to install cucumber as a gem or plugin'
    end
    task :wip do
      abort 'Cucumber rake task is not available. Be sure to install cucumber as a gem or plugin'
    end
  end
end

task :features => %w[features:ok features:wip]

task :default => :features
