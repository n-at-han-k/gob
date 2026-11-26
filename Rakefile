require "rake"
require "fileutils"

desc "Default: hello"
task default: [:hello]

desc "hello"
task :hello do
  sh "gob run test/cases/standard-lib-examples/001_hello/main.gob"
end

desc "test"
task :test do
  sh "bin/test"
end
