require "rake"
require "fileutils"

desc "Default: hello"
task default: [:hello]

desc "hello"
task :hello do
  sh "gob run test/cases/standard-lib-examples/001_hello/main.gob"
end

namespace :test do
  desc "Run transpilation case tests"
  task :transpilation do
    sh "bin/test"
  end

  desc "Run syntax unit tests"
  task :syntax do
    sh "bundle exec ruby -Ilib test/syntax/run.rb"
  end

  desc "Run the cops over test/cases, which is already in house style"
  task :format do
    sh "bundle exec ruby -Ilib -Itest test/format_check_test.rb"
  end

  desc "Run the cop unit tests"
  task :rules do
    sh "bundle exec ruby -Ilib -Itest test/validation_rules_test.rb"
  end
end

desc "test"
task :test => ["test:transpilation", "test:syntax", "test:rules", "test:format"]
