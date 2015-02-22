require 'yaml'
require 'optparse'
require 'ostruct'

class Cli
  attr_accessor :action

  def initialize
    @opt_parser = OptionParser.new { |p| option_parser_setup(p) }
    @opt = OpenStruct.new default_options
  end

  def run
    parse_parameters
    execute_action
  end

  private

  def parse_parameters
    @opt_parser.parse!
  end

  def print_help!
    $stderr << @opt_parser.help
    exit 1
  end

  def execute_action
    case @action
    when :help
      print_help!
    when :concat
      load_data
      extract_cassettes
    when :extract
      load_data
      extract_sessions
    when :single_file
      convert_file @input
    else
      fail ArgumentError "Unknown action #{action.inspect}"
    end
  end

  def extract_sessions
    selected_sessions.each { |s| extract_session(s) }
  end

  def extract_cassettes
    selected_cassettes.each { |c| concatinate_cassette(c) }
  end

  def extract_session(session)
    warn "Extracting #{session.id} from #{session.cassette} as #{session.output}"
    talk = Recording.new
    # talk.load_cassette cassette
    talk.set_options options_for_extraction
    talk.extract_session session
  end

  def concatinate_cassette(cassette)
    warn "Concatenating cassette #{cassette.id} as #{cassette.output}"
    recording = Recording.new
    recording.set_options options_for_extraction
    recording.extract_cassette cassette
  end

  def convert_file(filename)
    recording = Recording.new
    recording.load_file filename
    output = File.basename(filename, File.extname(filename))
    recording.filename = output
    set_recording_options recording
    recording.extract_video
  end

  def options_for_extraction
    OpenStruct.new verbose: !!@opt.verbose,
      quick_mode: !!@opt.quick_mode,
      destination: @opt.destination
  end

  def load_data
    fail ArgumentError, 'No plan given' unless @opt.plan_filename

    plan = YAML.load_file @opt.plan_filename
    fail 'No key \'cassettes\' found in plan' unless plan.key? 'cassettes'
    fail 'No key \'sessions\' found in plan' unless plan.key? 'sessions'

    @cassettes = plan['cassettes'].map do |id, data|
      [id, Cassette.new(data.merge 'id' => id)]
    end.to_h
    @sessions = plan['sessions'].map do |id, data|
      [id, Session.new(data.merge 'id' => id)]
    end.to_h
  end

  def selected_sessions
    if @opt.selected_session
      [@sessions.fetch(@opt.selected_session)]
    elsif @opt.selected_cassette
      @sessions.values.find_all { |s| s.cassette == @opt.selected_cassette }
    else
      @sessions.values
    end
  end

  def selected_cassettes
    if @opt.selected_cassette
      [@cassettes.fetch(@opt.selected_cassette)]
    else
      @cassettes.values
    end
  end

  def option_parser_setup(parser)
    @action = :help
    parser.banner = 'AVCHD cutter usage:'
    parser.on('--help', 'This help') { @action = :help }
    parser.on('--extract',
      'Extraction mode. Extract video from source') { |v| @action = :extract }
    parser.on('--concat',
      'Concat mode. Combine cassette into a single file') { |v| @action = :concat }
    parser.on('--plan example.yml',
      'Load session plan (YAML)') { |v| @opt.plan_filename = v }
    parser.on('--session identifier',
      'Select session (default all)') { |v| @opt.selected_session = v }
    parser.on('--cassette identifier',
      'Select cassette (default all)') { |v| @opt.selected_cassette = v }
    parser.on('--input file',
      'Specify input video file instead of sessions') do |v|
        @action = :single_file
        @input = v
      end
    parser.on('--destination directory',
      'Specify destination directory (default ./out)') do |v|
        @opt.destination = Pathname(v)
      end
    parser.on('--quick',
      'Don\'t transcode video') { |v| @opt.quick_mode = v }
    parser.on('--verbose',
      'Print more information') { |v| @opt.verbose = true }
  end

  def default_options
    { destination: Pathname.new('out') }
  end
end
