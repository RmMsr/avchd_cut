Cassette = Struct.new :id, :name do
  def initialize(parameters)
    data = parameters.dup
    members.each do |key|
      self[key] = data.delete(key.to_s)
    end
    fail "Unknown Cassette parameters: #{data.keys}" if data.any?
    self
  end

  def output
    id
  end
end
