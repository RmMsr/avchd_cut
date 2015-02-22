require 'cutter'

class Recording
  attr_accessor :cutter, :destination

  def initialize
    @cutter = Cutter.new
    @destination = Pathname.pwd
  end

  def load_file(filename)
    cutter.input = filename
  end

  def extract_session(session)
    cutter.cassette = session.cassette
    cutter.from = session.start
    cutter.duration = session.duration
    cutter.output = destination.join(session.output).to_s + '.mts'
    extract
  end

  def extract_cassette(cassette)
    cutter.cassette = cassette.id
    cutter.output = destination.join(cassette.id).to_s + '.mts'
    extract
  end

  def set_options(options)
    cutter.mode = options.quick_mode ? :quick : :normal
    cutter.verbose = options.verbose
    self.destination = options.destination
  end

  private

  def extract
    FileUtils.mkdir_p destination
    cutter.execute
  end
end
