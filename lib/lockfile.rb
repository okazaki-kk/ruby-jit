# frozen_string_literal: true

class Lockfile
  class MissingParentError < StandardError; end
  class NoPermissionError < StandardError; end
  class StaleLockError < StandardError; end

  def initialize(path)
    @file_path = path
    @lock_path = path.sub_ext('.lock')
    @lock = nil
  end

  def hold_for_update
    unless @lock
      flags = File::RDWR | File::CREAT | File::EXCL
      @lock = File.open(@lock_path, flags)
    end
    true
  rescue Errno::ENOENT => e
    raise MissingParentError, e.message
  rescue Errno::EACCES => e
    raise NoPermissionError, e.message
  end

  def write(str)
    raise_on_stale_lock
    @lock.write(str)
  end

  def commit
    raise_on_stale_lock
    @lock.close
    File.rename(@lock_path, @file_path)
    @lock = nil
  end

  private

  def raise_on_stale_lock
    raise StaleLockError, 'Stale lock' unless @lock
  end
end
