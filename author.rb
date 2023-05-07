# frozen_string_literal: true

Author = Struct.new(:name, :email, :time) do
  def to_s
    timestamp = time.strftime('%s %z')
    "#{name} <#{email}> #{timestamp}"
  end
end
