# SPDX-FileCopyrightText: Copyright (c) 2023-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rdoc'
require 'rdoc/task'
require 'rubocop/rake_task'
require 'rubygems'
require 'xcop/rake_task'

def name
  @name ||= File.basename(Dir['*.gemspec'].first, '.*')
end

def version
  Gem::Specification.load(Dir['*.gemspec'].first).version
end

task default: %i[clean test features rubocop xcop]

desc 'Run all unit tests'
Rake::TestTask.new(:test) do |test|
  Rake::Cleaner.cleanup_files(['coverage'])
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = false
end

desc 'Build RDoc documentation'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "#{name} #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc 'Run RuboCop on all directories'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.fail_on_error = true
  task.options = ['--display-cop-names']
end

Xcop::RakeTask.new(:xcop) do |task|
  task.includes = ['**/*.xml', '**/*.xsl', '**/*.xsd', '**/*.html']
  task.excludes = ['damsi/**', 'coverage/**', 'vendor/**']
end

require 'cucumber/rake/task'

Cucumber::Rake::Task.new(:features) do
  Rake::Cleaner.cleanup_files(['coverage'])
end
Cucumber::Rake::Task.new(:'features:html') do |t|
  t.profile = 'html_report'
end
