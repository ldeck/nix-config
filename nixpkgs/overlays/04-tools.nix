self: super: {
  emscriptenVersion = "1.39.20";

  kryptco.kr = super.stdenv.mkDerivation rec {
    name = "kr-${version}";
    version = "2.4.15";

    src = super.fetchFromGitHub {
      owner = "kryptco";
      repo = "kr";
      rev = "1937e31606e4dc0f7263133334d429f956502276";
      sha256 = "13ch85f1y4j2n4dbc6alsxbxfd6xnidwi2clibssk5srkz3mx794";
    };

    buildInputs = with super.pkgs;[ go ];

    makeFlags = [
      "PREFIX=$(out)"
      "GOPATH=$(out)/share/go"
      "GOCACHE=$(TMPDIR)/go-cache"
    ];

    preInstall = ''
      mkdir -p $out/share/go
    '';

    meta = with super.lib; {
      description = "A dev tool for SSH auth + Git commit/tag signing using a key stored in Krypton.";
      homepage = "https://krypt.co";
      license = licenses.unfreeRedistributable;
      platforms = platforms.linux ++ platforms.darwin;
      priority = 10;
    };
  };

  lzfse = super.lzfse.overrideAttrs(oldAttrs: rec {
    meta = oldAttrs.meta // {
      platforms = with super.stdenv.lib; platforms.all;
    };
  });
}
