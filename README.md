# yt-transcribe

A tiny bash wrapper that downloads a YouTube video with [yt-dlp](https://github.com/yt-dlp/yt-dlp) and transcribes it locally with [FluidAudio](https://github.com/FluidInference/FluidAudio) — Apple-Silicon-native Core ML ASR. No API keys, nothing leaves your machine.

```bash
yt-transcribe "https://www.youtube.com/watch?v=jNQXAC9IVRw"
# -> ./Me at the zoo.md
```

```markdown
# Me at the zoo

Source: https://www.youtube.com/watch?v=jNQXAC9IVRw

Alright, so here we are, one of the uh elephants. Um cool thing about
these guys is they is that they have really, really, really long um
fronts. And that's that's cool. And that's pretty much all there is
to say.
```

## Requirements

- macOS 14+ on Apple Silicon (FluidAudio CLI is mac-only and uses Core ML)
- Swift 6 toolchain (ships with Xcode / Command Line Tools)
- [`yt-dlp`](https://github.com/yt-dlp/yt-dlp) on `PATH`
- [`ffmpeg`](https://ffmpeg.org/) on `PATH` (used by yt-dlp for the audio extract step)

Quick install of those:

```bash
brew install yt-dlp ffmpeg
xcode-select --install   # if you don't already have the Swift toolchain
```

## Install

### Homebrew (recommended)

The repo doubles as a personal tap. Because it's not named `homebrew-yt-transcribe`, tap it by URL:

```bash
brew tap spookyuser/yt-transcribe https://github.com/spookyuser/yt-transcribe
brew install yt-transcribe
```

This builds FluidAudio's CLI from source (Swift, ~2 min on first install) and drops both binaries in your Homebrew prefix. `yt-dlp` and `ffmpeg` come along as dependencies.

Or, latest `main`:

```bash
brew install --HEAD spookyuser/yt-transcribe/yt-transcribe
```

### Manual

```bash
# 1. Build FluidAudio's CLI (cached at ~/Developer/FluidAudio by default)
git clone https://github.com/FluidInference/FluidAudio.git ~/Developer/FluidAudio
(cd ~/Developer/FluidAudio && swift build -c release)

# 2. Drop the wrapper somewhere on PATH
git clone https://github.com/spookyuser/yt-transcribe.git ~/Developer/yt-transcribe
ln -s ~/Developer/yt-transcribe/bin/yt-transcribe ~/.local/bin/yt-transcribe
```

First run downloads Core ML model weights from Hugging Face (~1 GB) and caches them under `~/Library/Application Support/FluidAudio/`. Subsequent runs are offline.

## Usage

```bash
yt-transcribe <youtube-url> [-o out.md] [extra fluidaudiocli args...]
```

| Default              | Override                                |
| -------------------- | --------------------------------------- |
| Model `v2` (English) | `--model-version v3` (multilingual)     |
| Output `./<title>.md`  | `-o some/path.md`                       |
| Audio cache `/tmp/yt-transcribe` | `YT_TRANSCRIBE_CACHE=…` env var |
| Binary `~/Developer/FluidAudio/.build/release/fluidaudiocli` | `FLUIDAUDIO_BIN=…` env var |

Any flag the wrapper doesn't recognize is forwarded to `fluidaudiocli transcribe`. The interesting ones:

- `--metadata` — confidence score, duration, etc.
- `--word-timestamps` — print word-level timings (note: lands in `os_log`, not stdout — use `--output-json` to capture them)
- `--output-json results.json` — full transcript + per-word timings
- `--custom-vocab vocab.txt` — bias the decoder toward domain-specific terms

Examples:

```bash
# Multilingual model
yt-transcribe "https://youtu.be/…" --model-version v3

# Save somewhere specific
yt-transcribe "https://youtu.be/…" -o ~/notes/talk.md

# Also dump word-level JSON
yt-transcribe "https://youtu.be/…" --output-json talk.json
```

The wrapper prints the output path on stdout, so:

```bash
$EDITOR "$(yt-transcribe https://youtu.be/...)"
```

## How it works

1. `yt-dlp --print "%(title)s"` to grab the video title (for the markdown filename).
2. `yt-dlp -f bestaudio[ext=m4a]` to pull only the audio track. Hashed filename in `/tmp/yt-transcribe`, so reruns on the same URL skip the download.
3. `fluidaudiocli transcribe …` does the work. FluidAudio's `AudioConverter` reads the m4a directly (no manual resampling — it normalizes to 16 kHz mono Float32 internally).
4. Stdout from the CLI is the transcript text; the wrapper wraps it with a small markdown header and writes the file.

## Updating

If you installed via brew:

```bash
brew update && brew upgrade yt-transcribe
```

If you installed manually:

```bash
cd ~/Developer/FluidAudio && git pull && swift build -c release
cd ~/Developer/yt-transcribe && git pull
```

## License

MIT. FluidAudio and yt-dlp have their own licenses — see their repos.
