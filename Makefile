deps:
	gem install bundler --no-rdoc --no-ri
	bundle install

test:
	bundle exec rake

.PHONY: deps test
