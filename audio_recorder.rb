#!/usr/bin/env ruby

require 'tempfile'
require 'fileutils'
require 'timeout'
require 'open3'

class AudioRecorder
  attr_reader :output_path, :recording

  def initialize
    @format = 'wav'
    @sample_rate = 44100
    @channels = 1
    @recording = false
    @ffmpeg_pid = nil
    @ffmpeg_stdin = nil
    @output_path = nil
  end

  def check_dependencies
    unless system("which ffmpeg > /dev/null 2>&1")
      puts "Error: 'ffmpeg' not found!"
      puts "Please install it with:"
      puts "  brew install ffmpeg"
      return false
    end
    puts "Using ffmpeg for audio recording"
    true
  end

  def create_temp_file
    @temp_file = Tempfile.new(['audio_recording', ".#{@format}"])
    @temp_file.close
    @temp_file.path
  end

  def stop_recording
    return unless @recording && @ffmpeg_pid

    @recording = false

    puts "Gracefully stopping ffmpeg process (PID: #{@ffmpeg_pid})..."
    if @ffmpeg_stdin && !@ffmpeg_stdin.closed?
      # Send 'q' to ffmpeg's stdin to quit gracefully
      @ffmpeg_stdin.write("q\n")
      @ffmpeg_stdin.close
    end

    @ffmpeg_pid = nil
    @ffmpeg_stdin = nil
    finalize_recording
  end

  def finalize_recording
    return unless @output_path

    # Give filesystem time to sync
    sleep(0.2)

    end_time = Time.now
    duration = end_time - @start_time

    if File.exist?(@output_path) && File.size(@output_path) > 0
      puts "\n✅ Recording completed successfully!"
      puts "Duration: #{'%.2f' % duration} seconds"
      puts "File size: #{File.size(@output_path)} bytes"
      puts "Temporary file: #{@output_path}"
    else
      puts "\n❌ Recording failed - output file is empty or doesn't exist"
    end
  end

  def start_recording(output_path)
    @output_path = output_path

    cmd = [
      "ffmpeg",
      "-f", "avfoundation",  # macOS AVFoundation
      "-i", ":0",            # Default microphone
      "-ar", @sample_rate.to_s,
      "-ac", @channels.to_s,
      "-y",                  # Overwrite output file
      output_path
    ]

    puts "Starting continuous recording..."
    puts "Command: #{cmd.join(' ')}"
    puts "Press Ctrl+C or send SIGTERM to stop and save the recording"

    @recording = true
    @start_time = Time.now

    # Spawn ffmpeg with stdin pipe so we can send commands to it
    @ffmpeg_stdin, stdout, stderr, wait_thr = Open3.popen3(*cmd)
    @ffmpeg_pid = wait_thr.pid

    # Wait for the process to complete
    begin
      wait_thr.join
      @ffmpeg_pid = nil
      @ffmpeg_stdin = nil
      # If we get here, recording ended naturally (which shouldn't happen in continuous mode)
      finalize_recording
    rescue => e
      # Process was interrupted
    end
  end

  def record
    @output_path = create_temp_file

    puts "\n🎙️  Audio Recorder - Continuous Mode"
    puts "Format: #{@format}"
    puts "Sample Rate: #{@sample_rate} Hz"
    puts "Channels: #{@channels == 1 ? 'Mono' : 'Stereo'}"
    puts "Output: #{@output_path}"
    puts "\n🔴 Recording started... Speak now!"

    begin
      start_recording(@output_path)
    rescue => e
      puts "\n❌ Recording failed: #{e.message}"
    end
  ensure
    # Clean up temp file if it exists
    if @temp_file && File.exist?(@temp_file.path)
      @temp_file.unlink
    end
  end

  def run
    puts "🎵 Audio Recorder v2.0 - Continuous Mode"
    puts "========================================"

    check_dependencies
    record
  end
end
