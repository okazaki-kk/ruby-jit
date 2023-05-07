init:
	bundle exec ruby lib/jit.rb init

delete:
	rm -rf .jit/

lint:
	bundle exec rubocop -A

commit:
	bundle exec ruby lib/jit.rb commit
