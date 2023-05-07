# frozen_string_literal: true

class Workspace
  IGNORE = ['.', '..', '.git', '.jit', 'vendor'].freeze

  def initialize(pathname)
    @pathname = pathname
  end

  def list_files
    Dir.entries(@pathname) - IGNORE
  end

  def read_file(path)
    File.read(@pathname.join(path))
  end

  def file_stat(path)
    File.stat(@pathname.join(path))
  end
end
