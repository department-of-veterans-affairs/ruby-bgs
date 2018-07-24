require "bundler/gem_tasks"
require "rubocop/rake_task"
require "bundler/audit/task"
require "rspec/core/rake_task"

task default: [:spec, :rubocop, "bundle:audit"]

RSpec::Core::RakeTask.new(:spec)

desc "Run RuboCop on the src directory"
RuboCop::RakeTask.new(:rubocop) do |task|
  task.patterns = ["lib/**/*.rb"]
  # only show the files with failures
  task.formatters = ["files"]
  # Trigger failure for CI
  task.fail_on_error = true
end

desc "Run bundle-audit"
Bundler::Audit::Task.new
