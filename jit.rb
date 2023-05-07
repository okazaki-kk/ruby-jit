# frozen_string_literal: true

require 'fileutils'
require 'pathname'
require 'dotenv'

require_relative 'workspace'
require_relative 'database'
require_relative 'blob'
require_relative 'tree'
require_relative 'entry'
require_relative 'author'
require_relative 'commit'
require_relative 'refs'

command = ARGV.shift
Dotenv.load

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

when 'commit'
  root_path = Pathname.new(Dir.getwd)
  jit_path = root_path.join('.jit')
  db_path = jit_path.join('objects')

  workspace = Workspace.new(root_path)
  database = Database.new(db_path)
  refs = Refs.new(jit_path)

  entries = workspace.list_files.map do |file|
    data = workspace.read_file(file)
    blob = Blob.new(data)

    database.store(blob)

    Entry.new(file, blob.oid)
  end

  tree = Tree.new(entries)
  database.store(tree)

  puts "tree: #{tree.oid}"

  parent = refs.read_head
  name = ENV.fetch('JIT_AUTHOR_NAME')
  email = ENV.fetch('JIT_AUTHOR_EMAIL')
  author = Author.new(name, email, Time.now)
  message = $stdin.read

  commit = Commit.new(parent, tree.oid, author, message)
  database.store(commit)
  refs.update_head(commit.oid)

  is_root = parent.nil? ? 'root-commit' : ''
  puts "[#{is_root}#{commit.oid}] #{message.lines.first}}"
  exit 0

else
  warn "jit: '#{command}' is not a jit command. See 'jit --help'."
  exit 1
end
