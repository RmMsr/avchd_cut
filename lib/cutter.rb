require 'pathname'
require 'ostruct'

class Cutter
  attr_accessor :mode, :verbose
  attr_reader :options

  def initialize
    @options = OpenStruct.new ffmpeg_defaults
    @mode = :normal
    @verbose = false
  end

  def cassette=(directory_name)
    path = Pathname.new(directory_name)
    @options.source_dir = path.join('PRIVATE', 'AVCHD', 'BDMV', 'STREAM')
  end

  def input=(file_name)
    @options.source_file = file_name
  end

  def from=(time)
    @options.from = time
  end

  def to=(time)
    @options.to = time
  end

  def duration=(time)
    @options.duration = time
  end

  def output=(filename)
    @options.output = filename
  end

  def execute
    command = build_command_from_options
    warn "Running command:\n#{command}" if verbose
    system command
  end

  private

  def parts
    Pathname.glob(options.source_dir + '*.MTS')
  end

  def build_command_from_options
    arg = ['ffmpeg']
    arg += global_options
    arg += input_options
    arg += input_file
    arg += output_options
    arg += output_file
    arg.join(' ')
  end

  def global_options
    arg = []
    arg << "-loglevel #{verbose ? 'info' : 'warning'}"
    arg << '-y' if options.overwrite
    arg << "-threads #{options.number_of_threads}" if options.number_of_threads
    arg
  end

  def input_options
    []
  end

  def input_file
    if @options.source_file
      ["-i #{options.source_file}"]
    else
      ["-i 'concat:#{parts.join('|')}'"]  # Concat parts on file level
    end
  end

  def output_options
    arg = []
    arg << "-ss #{options.from}" if options.from
    arg << '-dn' if options.strip_data
    if options.to
      arg << "-to #{options.to}"
    elsif options.duration
      arg << "-t #{options.duration}"
    end
    if mode == :quick
      arg << '-codec:v copy'
      arg << "-codec:a #{audio_codec_param}"
    else
      arg << "-codec:v #{video_codec_param}"
      arg << "-codec:a #{audio_codec_param}"
    end
    arg
  end

  def video_codec_param
    'libx264 -profile:v main -level:v 3.1 -b:v 2400k -preset fast ' \
      '-filter:v \'hqdn3d=4.0:3.0:6.0:4.5,unsharp=5:5:1.0:5:5:0.0, ' \
      'mp=eq2=1.3:1.2:0.05:1:0.95:1:1,scale=1280:-1\''
  end

  def audio_codec_param
    %s(libfdk_aac -ac 1 -b:a 128k -filter:a 'pan=1c|c0=c0')
  end

  def output_file
    ["'#{options.output}'"]
  end

  def ffmpeg_defaults
    {
      overwrite: true,      # assume yes
      number_of_threads: 0, # 1-n, 0 auto
      strip_data: true      # disable data streams
    }
  end
end
