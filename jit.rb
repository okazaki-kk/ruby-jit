# frozen_string_literal: true

require 'fileutils'
require 'pathname'

command = ARGV.shift

case command
when 'init'
  path = ARGV.fetch(0, Dir.getwd)

  root_path = Pathname.new(File.expand_path(path))
  jit_path = root_path.join('.jit')

  %w[objects refs].each do |dir|
    FileUtils.mkdir_p(jit_path.join(dir))
  rescue Errno::EACCES => e
    warn "error: #{e.message}"
    exit 1
  end

  puts "initialized empty jit repository in #{jit_path}"
  exit 0
else
  warn "jit: '#{command}' is not a jit command. See 'jit --help'."
  exit 1
end
