A software to cut single videos from an [AVCHD](http://en.wikipedia.org/wiki/AVCHD) recording.

## Usage

It requires:

  * a recent version of Ruby (tested with 2.1)
  * the [FFMPEG](http://ffmpeg.org/) binary

Now checkout the repository.

To use `avchd_cut` open your shell and change to the directory where your
recordings are located. It should contain a structure like this:

    {cassette_name}
    - PRIVATE
      - AVCHD
        - BDMV
          - STREAM
            - 00000.MTS
            - 00001.MTS
            - ...

Call the executable `bin/avchd_cut.rb` with the appropriate parameters:

    AVCHD cutter usage:
            --help                       This help
            --extract                    Extraction mode. Extract video from source
            --concat                     Concat mode. Combine cassette into a single file
            --plan example.yml           Load session plan (YAML)
            --session identifier         Select session (default all)
            --cassette identifier        Select cassette (default all)
            --input file                 Specify input video file instead of sessions
            --destination directory      Specify destination directory (default ./out)
            --quick                      Don't transcode video
            --verbose                    Print more information
