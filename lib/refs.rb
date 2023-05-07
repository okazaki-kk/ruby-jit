# frozen_string_literal: true

require_relative 'lockfile'

class Refs
  class LockDeniedError < StandardError; end

  def initialize(pathname)
    @pathname = pathname
  end

  def update_head(oid)
    lockfile = Lockfile.new(head_path)

    raise LockDeniedError, "Could not acquire lock on file #{head_path}" unless lockfile.hold_for_update

    lockfile.write(oid)
    lockfile.write("\n")
    lockfile.commit
  end

  def read_head
    File.read(head_path).strip if File.exist?(head_path)
  end

  private

  def head_path
    @pathname.join('HEAD')
  end
end
