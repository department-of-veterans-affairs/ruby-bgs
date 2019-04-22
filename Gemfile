source "https://rubygems.org"
gemspec

gem "rake"

group :development, :test do
  gem "bundler-audit", git: "https://github.com/rubysec/bundler-audit"
  gem "pry"
  gem "rspec"
  gem "rubocop"
  # nokogiri versions before 1.10.3 are affected by CVE-2019-11068.
  # Explicitly define nokogiri version here to avoid that.
  # https://github.com/sparklemotion/nokogiri/issues/1892
  gem "nokogiri", "1.10.3"
end
