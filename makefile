init:
	bundle exec ruby jit.rb init

delete:
	rm -rf .jit/

lint:
	bundle exec rubocop -A *.rb

commit:
	bundle exec ruby jit.rb commit
