require 'rake'
# prepare rake tasks required for test
app = Rake.application
app.init
app.add_import 'Rakefile'
app.load_rakefile

guard :minitest,all_on_start: false  do
  # with Minitest::Unit
  watch(%r{^test/(.*)\/?test_(.*)\.rb$})
  watch(%r{^test/(.*)\/?(.*)_test\.rb$})
  watch(%r{^lib/(.*/)?([^/]+)\.rb$})     { |m| "test/#{m[1]}test_#{m[2]}.rb" }

end
