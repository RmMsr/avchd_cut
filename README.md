A software to extract videos from an
[AVCHD](http://en.wikipedia.org/wiki/AVCHD) recording.

## Basic usage

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

## Defining sessions

In order to cut out single sessions we have to provide basic information like
name of the cassette, start time and end time. The data is provided in form
of a YAML session plan. It looks like this:

    ---
    cassettes:
      event_tape_1:
        name: Day 1
      event_tape_2:
        name: Day 2
    sessions:
      day1-ses1:
        cassette: event_tape_1
        prefix:   eventName
        name:     Opening talk
        start:    00:45:12
        stop:     01:05:58
      day1-ses2:
        cassette: event_tape_1
        prefix:   eventName
        name:     First talk
        start:    01:20:34.4
        stop:     01:50:00
      day2-ses1:
        cassette: event_tape_2
        prefix:   eventName
        name:     Another session
        start:    00:05:44
        stop:     03:00:30.5

The difficult part is to know when a session starts or ends exactly on the
cassettes. To get this numbers we look at the complete video of one cassette.
If you don't have a media player that understands AVCHD recordings you can
use the `--concat` option to create one large file of one cassette.

    avchd_cut.rb --concat --plan sessions.yml
    # will create ./out/{cassette}.mts

To check if your timestamps are correct extract that session without time
consuming transcoding.

    avchd_cut.rb --extract --plan sessions.yml --session talk3 --quick
    # will create ./out/{prefix}-{session}-{name}.mts

If you don't like the result just adjust the session plan and repeat the
last command until you are satisfied.

## Acknowledgement

Thanks [@punkrats](https://github.com/punkrats) for getting me started with
his [eurucamp_cutter.rb](https://gist.github.com/punkrats/58c958b70fa57fe0b576)

---

Distributed freely under the MIT license.
