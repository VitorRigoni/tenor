#!/usr/bin/env ruby

require_relative 'audio_recorder'
require_relative 'transcriber'

class App
  def initialize
    @audio_recorder = AudioRecorder.new
    @transcriber = Transcriber.new
    @audio_file_path = nil
  end

  def check_dependencies
    puts "🔍 Checking dependencies..."

    # Check audio recording dependencies
    unless @audio_recorder.check_dependencies
      puts "❌ Audio recording dependencies not met"
      return false
    end

    # Check transcription dependencies
    unless @transcriber.check_dependencies
      puts "❌ Transcription dependencies not met"
      return false
    end

    puts "✅ All dependencies satisfied"
    return true
  end

  def setup_signal_handlers
    Signal.trap('TERM') do
      puts "\n\n🛑 Received SIGTERM, stopping recording and transcribing..."
      stop_and_transcribe
      exit 0
    end

    Signal.trap('INT') do
      puts "\n\n⏹️  Received SIGINT (Ctrl+C), stopping recording and transcribing..."
      stop_and_transcribe
      exit 0
    end
  end

  def stop_and_transcribe
    # Stop the audio recorder and get the file path
    @audio_file_path = stop_recording

    if @audio_file_path
      transcribe_audio
    else
      puts "❌ No audio file to transcribe"
    end
  end

  def stop_recording
    # Call the audio recorder's stop method and capture the file path
    puts "Recording: #{@audio_recorder.recording}"
    if @audio_recorder.recording
      puts "Output path: #{@audio_recorder.output_path}"
      @audio_recorder.stop_recording
      return @audio_recorder.output_path
    end
    puts "No audio file to transcribe"
    nil
  end

  def transcribe_audio
    return unless @audio_file_path

    puts "\n🔄 Starting automatic transcription..."

    result = @transcriber.transcribe_file(@audio_file_path)

    if result
      puts "\n🎉 Pipeline completed successfully!"
      puts "Audio: #{@audio_file_path}"
      puts "Transcript: #{result}"
      system("cursor #{result}")
    else
      puts "\n⚠️  Transcription failed, but audio was saved"
    end
  end

  def run
    puts "🎵 Tenor"
    puts "========"

    unless check_dependencies
      puts "❌ Cannot start due to missing dependencies"
      exit 1
    end

    puts "\n📝 This will:"
    puts "1. Record audio continuously from your microphone"
    puts "2. When stopped, automatically transcribe the audio to text"
    puts "3. Save both the audio file and transcript"
    puts "\nPress Ctrl+C or send SIGTERM to stop recording and start transcription"

    # Set up our signal handlers instead of the audio recorder's
    setup_signal_handlers

    # Start recording (this will block until interrupted)
    puts "\n🔴 Starting recording..."
    @audio_recorder.record
  end
end

App.new.run
