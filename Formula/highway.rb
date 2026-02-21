class Highway < Formula
  desc "Model routing for Claude Code — route tasks to haiku/sonnet/opus automatically"
  homepage "https://github.com/nekosheen/highway"
  version "0.1.0"

  # Update this URL and sha256 when you publish a release tarball
  url "https://github.com/nekosheen/highway/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "525f4f26feafb09370086fbab3a9f40bf6eb4e82eca067a151d85245be9f2142"

  depends_on "python3"

  def install
    # Install all files preserving directory structure
    libexec.install "bin", "lib", "templates"

    # Make scripts executable
    chmod 0755, libexec/"bin/highway"
    chmod 0755, libexec/"lib/install.sh"
    chmod 0755, libexec/"lib/uninstall.sh"
    chmod 0755, libexec/"lib/status.sh"
    chmod 0755, libexec/"templates/hook.sh"

    # Create a symlink in the Homebrew bin directory
    bin.install_symlink libexec/"bin/highway"
  end

  def caveats
    <<~EOS
      To enable model routing in Claude Code, run:
        highway install

      This will patch ~/.claude/CLAUDE.md and ~/.claude/settings.json.
      To remove: highway uninstall
    EOS
  end

  test do
    output = shell_output("#{bin}/highway version")
    assert_match "highway v#{version}", output
  end
end
