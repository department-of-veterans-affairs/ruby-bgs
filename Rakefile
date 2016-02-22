require "bundler/gem_tasks"
require "rubocop/rake_task"

task default: [:rubocop]

desc 'Run RuboCop on the src directory'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.patterns = ['lib/**/*.rb']
  # only show the files with failures
  task.formatters = ['files']
  # Trigger failure for CI
  task.fail_on_error = true
end
