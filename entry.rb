# frozen_string_literal: true

class Entry
  attr_accessor :name, :oid

  def initialize(name, oid)
    @name = name
    @oid = oid
  end
end
