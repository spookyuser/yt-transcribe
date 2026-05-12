class YtTranscribe < Formula
  desc "Transcribe YouTube videos locally on Apple Silicon with yt-dlp + FluidAudio"
  homepage "https://github.com/spookyuser/yt-transcribe"
  url "https://github.com/spookyuser/yt-transcribe/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "958f1e7602cd20f4e6855d00f5444efdf9ab458f528f0111175a2b539a263a83"
  license "MIT"
  head "https://github.com/spookyuser/yt-transcribe.git", branch: "main"

  depends_on xcode: :build
  depends_on arch: :arm64
  depends_on "ffmpeg"
  depends_on macos: :sonoma
  depends_on "yt-dlp"

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
