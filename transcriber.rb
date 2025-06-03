#!/usr/bin/env ruby

require 'tempfile'
require 'open3'
require 'json'

class Transcriber
  def initialize(model: 'mlx-community/whisper-large-v3-mlx', language: nil, output_dir: './transcripts')
    @model = model
    @language = language
    @output_dir = output_dir
    @mlx_whisper_path = nil

    ensure_output_directory
  end

  def check_dependencies
    # Check if mlx_whisper command is available
    unless system("which mlx_whisper > /dev/null 2>&1")
      puts "❌ MLX Whisper command not found!"
      puts "Please install it with:"
      puts "  pip install mlx-whisper"
      puts "\nOr follow the installation guide at:"
      puts "  https://github.com/ml-explore/mlx-examples/tree/main/whisper"
      puts "\nAfter installation, make sure 'mlx_whisper' is in your PATH"
      return false
    end

    puts "✅ MLX Whisper command found"
    true
  end

  def ensure_output_directory
    unless Dir.exist?(@output_dir)
      FileUtils.mkdir_p(@output_dir)
      puts "📁 Created transcripts directory: #{@output_dir}"
    end
  end

  def transcribe_file(audio_file_path)
    unless File.exist?(audio_file_path)
      puts "❌ Audio file not found: #{audio_file_path}"
      return nil
    end

    unless check_dependencies
      puts "❌ Dependencies not met for transcription"
      return nil
    end

    puts "\n🎯 Starting transcription..."
    puts "Audio file: #{audio_file_path}"
    puts "Model: #{@model}"
    puts "Language: #{@language || 'auto-detect'}"

    # Create output filename
    base_name = File.basename(audio_file_path, File.extname(audio_file_path))
    timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
    output_file = File.join(@output_dir, "#{base_name}_#{timestamp}.txt")

    # Build the mlx_whisper command
    cmd = build_transcription_command(audio_file_path, output_file)

    puts "Running: #{cmd.join(' ')}"

    # Execute transcription
    start_time = Time.now
    success = execute_transcription(cmd)
    end_time = Time.now

    if success
      duration = end_time - start_time
      puts "\n✅ Transcription completed successfully!"
      puts "Duration: #{'%.2f' % duration} seconds"

      if File.exist?(output_file)
        file_size = File.size(output_file)
        puts "Output file: #{output_file}"
        puts "File size: #{file_size} bytes"

        # Display a preview of the transcription
        display_transcription_preview(output_file)

        return output_file
      else
        puts "❌ Output file was not created"
        return nil
      end
    else
      puts "❌ Transcription failed"
      return nil
    end
  end

  private

  def build_transcription_command(input_file, output_file)
    cmd = [
      "mlx_whisper",
      input_file,
      "--model", @model,
      "--output-name", output_file,
    ]

    # Add language if specified
    if @language
      cmd.concat(["--language", @language])
    end

    cmd
  end

  def execute_transcription(cmd)
    begin
      stdout, stderr, status = Open3.capture3(*cmd)

      if status.success?
        puts "📝 Transcription output:"
        puts stdout unless stdout.empty?
        return true
      else
        puts "❌ Transcription error:"
        puts stderr unless stderr.empty?
        return false
      end
    rescue => e
      puts "❌ Failed to execute transcription: #{e.message}"
      return false
    end
  end

  def display_transcription_preview(file_path)
    begin
      content = File.read(file_path).strip

      if content.empty?
        puts "⚠️  Transcription file is empty"
        return
      end

      puts "\n📄 Transcription preview:"
      puts "=" * 50

      # Show first 200 characters
      if content.length > 200
        puts content[0..200] + "..."
        puts "\n(Showing first 200 characters of #{content.length} total)"
      else
        puts content
      end

      puts "=" * 50
    rescue => e
      puts "❌ Could not read transcription file: #{e.message}"
    end
  end

  # Class method for quick transcription
  def self.transcribe(audio_file_path, **options)
    transcriber = new(**options)
    transcriber.transcribe_file(audio_file_path)
  end
end

# Run transcription if called directly
if __FILE__ == $0
  if ARGV.empty?
    puts "Usage: #{$0} <audio_file_path> [model] [language]"
    puts "Example: #{$0} recording.wav tiny en"
    exit 1
  end

  audio_file = ARGV[0]
  model = ARGV[1] || 'tiny'
  language = ARGV[2]

  options = { model: model }
  options[:language] = language if language

  Transcriber.transcribe(audio_file, **options)
end
