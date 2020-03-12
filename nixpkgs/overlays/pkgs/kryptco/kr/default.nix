{ buildGoModule, fetchFromGitHub, lib }:

buildGoModule rec {
  name = "kr-${version}";
  version = "2.4.15";

  src = fetchFromGitHub {
      owner = "kryptco";
      repo = "kr";
      rev = "1937e31606e4dc0f7263133334d429f956502276";
      sha256 = "13ch85f1y4j2n4dbc6alsxbxfd6xnidwi2clibssk5srkz3mx794";
  };

  modRoot = "./src";
  goDeps = ./deps.nix;
  modSha256 = "1q6vhdwz26qkpzmsnk6d9j6hjgliwkgma50mq7w2rl6rkwashvay";

  meta = with lib; {
    description = "A dev tool for SSH auth + Git commit/tag signing using a key stored in Krypton.";
    homepage = "https://krypt.co";
    license = licenses.unfreeRedistributable;
    platforms = platforms.linux ++ platforms.darwin;
  };
}
