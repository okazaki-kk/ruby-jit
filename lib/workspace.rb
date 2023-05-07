# frozen_string_literal: true

class Workspace
  IGNORE = ['.', '..', '.git', '.jit', 'vendor', '.env'].freeze

  def initialize(pathname)
    @pathname = pathname
  end

  def list_files(dir = @pathname)
    filenames = Dir.entries(dir) - IGNORE

    filenames.flat_map do |filename|
      path = dir.join(filename)
      if File.directory?(path)
        list_files(path)
      else
        path.relative_path_from(@pathname)
      end
    end
  end

  def read_file(path)
    File.read(@pathname.join(path))
  end

  def file_stat(path)
    File.stat(@pathname.join(path))
  end
end
