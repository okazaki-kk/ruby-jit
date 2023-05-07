# frozen_string_literal: true

require 'digest/sha1'
require 'zlib'

class Database
  def initialize(pathname)
    @pathname = pathname
  end

  def store(object)
    str = object.to_s.force_encoding(Encoding::ASCII_8BIT)
    content = "#{object.type} #{str.bytesize}\0#{str}"

    object.oid = Digest::SHA1.hexdigest(content)
    write_object(object.oid, content)
  end

  def write_object(oid, content)
    object_path = @pathname.join(oid[0..1], oid[2..])
    dirname = object_path.dirname
    temp_path = dirname.join(generate_temp_name)

    begin
      flags = File::RDWR | File::CREAT | File::EXCL
      file = File.open(temp_path, flags)
    rescue Errno::ENOENT
      Dir.mkdir(dirname)
      file = File.open(temp_path, flags)
    end

    compressed = Zlib::Deflate.deflate(content, Zlib::BEST_SPEED)
    file.write(compressed)
    file.close

    File.rename(temp_path, object_path)
  end

  TEMP_CHARS = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
  def generate_temp_name
    "temp_obj_#{Array.new(6) { TEMP_CHARS.sample }.join}"
  end
end
