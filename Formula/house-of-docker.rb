class HouseOfDocker < Formula
  desc "Local Docker stack for experimenting with the IOTA gas station"
  homepage "https://github.com/victorjambo/house-of-docker"
  url "https://github.com/victorjambo/house-of-docker/archive/7255a94fbaa3062711d2d7f067767a92fa187f07.tar.gz"
  sha256 "f3e4fab3b481bfd633508abd343cb4bd6cf477d15b16c8f686a1e77182457b07"
  license :cannot_represent
  head "https://github.com/victorjambo/house-of-docker.git", branch: "main"

  depends_on "docker"
  depends_on "mkcert" => :recommended

  def install
    bin.install "gas-station-tool.sh" => "gas-station-tool"

    pkgshare.install "Makefile", "README.md", "docker-compose.yml",
                     "gas-station-config.yaml", "config.yaml"
    pkgshare.install "docs" if (buildpath/"docs").exist?
    pkgshare.install "nginx" if (buildpath/"nginx").exist?
    pkgshare.install "certs" if (buildpath/"certs").exist?
  end

  def caveats
    <<~EOS
      The Compose files and docs were installed into:
        #{pkgshare}

      To spin the stack up:
        mkdir -p ~/house-of-docker
        cp -R #{pkgshare}/* ~/house-of-docker
        cd ~/house-of-docker && make up
    EOS
  end

  test do
    ENV["HOD_SKIP_DOCKER"] = "1"
    output = shell_output("#{bin}/gas-station-tool --help")
    assert_match "docker run", output
  end
end
