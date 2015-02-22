Session = Struct.new :id, :name, :cassette, :prefix, :start, :stop do
  def initialize(parameters)
    data = parameters.dup
    members.each do |key|
      self[key] = data.delete(key.to_s)
    end
    fail "Unknown Session parameters: #{data.keys}" if data.any?
    self
  end

  def filename_base
    simplified_name = name.gsub(/[^A-Za-z0-9_]+/, '_')
    "#{prefix}-#{id}-#{simplified_name}"
  end

  def output
    filename_base
  end

  def duration
    return nil unless start && stop
    stop - start
  end
end
