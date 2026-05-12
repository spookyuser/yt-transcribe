class YtTranscribe < Formula
  desc "Transcribe YouTube videos locally on Apple Silicon with yt-dlp + FluidAudio"
  homepage "https://github.com/spookyuser/yt-transcribe"
  url "https://github.com/spookyuser/yt-transcribe/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "PLACEHOLDER_FILLED_AFTER_TAG_PUSH"
  license "MIT"
  head "https://github.com/spookyuser/yt-transcribe.git", branch: "main"

  depends_on arch: :arm64
  depends_on macos: :sonoma
  depends_on "ffmpeg"
  depends_on "yt-dlp"
  depends_on xcode: :build

  resource "fluidaudio" do
    url "https://github.com/FluidInference/FluidAudio/archive/refs/tags/v0.14.5.tar.gz"
    sha256 "5597c588a85fbf8c301fed448ed132239074b033b74239c9d9ce29e8540939f3"
  end

  def install
    resource("fluidaudio").stage do
      system "swift", "build", "-c", "release", "--disable-sandbox"
      libexec.install ".build/release/fluidaudiocli"
    end

    inreplace "bin/yt-transcribe",
              "$HOME/Developer/FluidAudio/.build/release/fluidaudiocli",
              "#{libexec}/fluidaudiocli"
    bin.install "bin/yt-transcribe"
  end

  test do
    output = shell_output("#{bin}/yt-transcribe 2>&1", 64)
    assert_match "usage:", output
  end
end
