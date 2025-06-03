# Tenor

A Ruby application that records audio from your microphone and automatically transcribes it to text using MLX Whisper.

## Features

- ✅ **Continuous audio recording** from microphone
- ✅ **Automatic transcription** using MLX Whisper (Apple Silicon optimized)
- ✅ **Graceful shutdown** with SIGTERM/SIGINT handling
- ✅ **Bundler integration** for consistent Ruby environment
- ✅ **Auto-opens transcripts** in Cursor editor when complete
- ✅ **Timestamped output files** for easy organization

## Prerequisites

### Required Dependencies

1. **ffmpeg** - for audio recording
   ```bash
   brew install ffmpeg
   ```

2. **MLX Whisper** - for audio transcription
   ```bash
   pip install mlx-whisper
   ```

3. **Ruby 3.0+** with Bundler

## Installation

1. **Clone/setup the project:**
   ```bash
   bundle install
   ```

2. **Verify dependencies:**
   The app will check all dependencies on startup and guide you through any missing requirements.

## Usage

### Quick Start
```bash
./bin/tenor
```

### What Happens:
1. **Dependency Check**: Verifies ffmpeg and mlx_whisper are available
2. **Start Recording**: Begins continuous microphone recording
3. **Record Audio**: Speak into your microphone (no time limit)
4. **Stop Recording**: Press `Ctrl+C` when finished
5. **Auto-Transcribe**: Automatically transcribes the audio using MLX Whisper
6. **Open Result**: Opens the transcript file in Cursor editor

### Example Session

```bash
$ ./bin/tenor

🎵 Tenor
========
🔍 Checking dependencies...
✅ MLX Whisper command found
✅ Using ffmpeg for audio recording
✅ All dependencies satisfied

📝 This will:
1. Record audio continuously from your microphone
2. When stopped, automatically transcribe the audio to text
3. Save both the audio file and transcript

Press Ctrl+C or send SIGTERM to stop recording and start transcription

🔴 Starting recording...
[Recording from microphone...]

^C
⏹️  Received SIGINT (Ctrl+C), stopping recording and transcribing...
Gracefully stopping ffmpeg process...

🔄 Starting automatic transcription...
🎯 Starting transcription...
Audio file: /tmp/audio_recording20240602-12345.wav
Model: mlx-community/whisper-large-v3-mlx
Language: auto-detect

✅ Transcription completed successfully!
Duration: 3.45 seconds

📄 Transcription preview:
==================================================
Hello, this is a test recording. The quick brown
fox jumps over the lazy dog. This demonstrates
the audio recording and transcription pipeline.
==================================================

🎉 Pipeline completed successfully!
Audio: /tmp/audio_recording20240602-12345.wav
Transcript: ./transcripts/audio_recording20240602-12345_20240602_143022.txt
[Opens transcript in Cursor]
```

## Configuration

### Transcription Model
The app uses `mlx-community/whisper-large-v3-mlx` by default for high-quality transcription. You can modify this in `transcriber.rb`:

```ruby
@transcriber = Transcriber.new(model: 'tiny')  # For faster, less accurate transcription
```

### Audio Settings
Audio is recorded with these fixed settings:
- **Format**: WAV
- **Sample Rate**: 44,100 Hz
- **Channels**: Mono (1 channel)

## File Structure

```
your-project/
├── audio_recorder.rb    # Audio recording class
├── transcriber.rb       # MLX Whisper transcription class
├── app.rb              # Integrated pipeline
├── bin/
│   └── tenor           # Bundler binstub
├── transcripts/        # Output directory for transcripts
├── Gemfile            # Ruby dependencies
└── README.md          # This file
```

## Output Files

### Audio Files
- **Location**: Temporary files (automatically cleaned up)
- **Format**: WAV files with unique timestamps

### Transcript Files
- **Location**: `./transcripts/` directory
- **Format**: Plain text files
- **Naming**: `audio_recording_YYYYMMDD_HHMMSS.txt`
- **Content**: Transcribed speech in plain text

## Architecture

The application consists of three main components:

1. **AudioRecorder** (`audio_recorder.rb`)
   - Handles microphone input via ffmpeg
   - Manages graceful shutdown with signal handling
   - Creates temporary audio files

2. **Transcriber** (`transcriber.rb`)
   - Calls MLX Whisper command line tool
   - Processes audio files into text
   - Manages transcript file output

3. **App** (`app.rb`)
   - Orchestrates the complete pipeline
   - Handles signal coordination between components
   - Manages the workflow from recording → transcription → display

## Troubleshooting

### Permission Issues
```bash
chmod +x bin/tenor
```

### Microphone Permissions
If recording fails, enable microphone access for Terminal in:
**System Preferences > Security & Privacy > Privacy > Microphone**

### MLX Whisper Issues
Ensure the command is in your PATH:
```bash
which mlx_whisper  # Should return a path
```

If not found, try reinstalling:
```bash
pip install --upgrade mlx-whisper
```

### Dependencies Check
Run the app once to see a complete dependency check with specific installation instructions for any missing components.

## Development

### Running Individual Components

**Audio recording only:**
```bash
ruby audio_recorder.rb
```

**Transcription only:**
```bash
ruby transcriber.rb path/to/audio.wav
```

**Full pipeline:**
```bash
bundle exec ruby app.rb
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### What this means:
- ✅ **Free to use** for any purpose (personal, commercial, etc.)
- ✅ **Free to modify** and distribute
- ✅ **Attribution required** - include the copyright notice in your copies
- ✅ **No warranty** - provided as-is

### Attribution
If you use this code in your project, please include:
```
Tenor by Vitor Rigoni
https://github.com/VitorRigoni/tenor
```
