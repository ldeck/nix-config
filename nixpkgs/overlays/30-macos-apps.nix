self: super: {

installApplication =
  { name, appname ? name, version, src, description, homepage,
    postInstall ? "", sourceRoot ? ".", ... }:
  with super; stdenv.mkDerivation {
    name = "${name}-${version}";
    version = "${version}";
    src = src;
    buildInputs = [ undmg unzip ];
    sourceRoot = sourceRoot;
    phases = [ "unpackPhase" "installPhase" ];
    installPhase = ''
      mkdir -p "$out/Applications/${appname}.app"
      cp -pR * "$out/Applications/${appname}.app"
    '' + postInstall;
    meta = with stdenv.lib; {
      description = description;
      homepage = homepage;
      maintainers = with maintainers; [ jwiegley ];
      platforms = platforms.darwin;
    };
  };

Docker = self.installApplication rec {
  name = "Docker";
  version = "2.2.0.5";
  revision = "43884";
  sourceRoot = "Docker.app";
  src = super.fetchurl {
    url = "https://download.docker.com/mac/stable/${revision}/Docker.dmg";
    sha256 = "14dgvicl56lzr0p0g1ha7zkqv7wk3kxl90a6zk2cswyxn93br04s";
    # https://github.com/Homebrew/homebrew-cask/blob/master/Casks/docker.rb
  };
  description = ''
    Docker CE for Mac is an easy-to-install desktop app for building,
    debugging, and testing Dockerized apps on a Mac
  '';
  homepage = https://store.docker.com/editions/community/docker-ce-desktop-mac;
  appcast = https://download.docker.com/mac/stable/appcast.xml;

  postInstall = ''
    mkdir -p $out/bin
    ln -fs "$out/Applications/${name}.app/Contents/Resources/bin/docker" $out/bin/docker
    ln -fs "$out/Applications/${name}.app/Contents/Resources/bin/docker-compose/docker-compose" $out/bin/docker-compose
    #todo: add etc/docker[-compose].[bash|zsh]-completion
  '';
  };

Firefox = self.installApplication rec {
  name = "Firefox";
  version = "77.0.1";
  sourceRoot = "Firefox.app";
  src = super.fetchurl {
    name = "Firefox-${version}.dmg";
    url = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/${version}/mac/en-US/Firefox+${version}.dmg";
    sha256 = "1i9fy8mqz5p71w2ms7ym8q6xwbq162blqm6l5rl36iv44hwdj5l8";
  };
  postInstall = ''
    mkdir -p $out/bin
    ln -fs $out/Applications/${name}.app/Contents/MacOS/firefox $out/bin/firefox
    ln -fs $out/Applications/${name}.app/Contents/MacOS/firefox-bin $out/bin/firefox-bin
  '';
  description = "The Firefox web browser";
  homepage = https://www.mozilla.org/en-US/firefox/;
  appcast = https://www.mozilla.org/en-US/firefox/releases/;
};

FreeRuler = self.installApplication rec {
  name = "FreeRuler";
  version = "2.0.3";
  sourceRoot = "Free Ruler.app";
  src = super.fetchurl {
    url = "https://github.com/pascalpp/FreeRuler/releases/download/v${version}/free-ruler-${version}.zip";
    sha256 = "17fsjb2x5037k31ig4czgnv6s3dii3kjkczdpak4kqhkq43qjhma";
  };
  description = "A ruler application for macOS";
  homepage = "http://www.pascal.com/software/freeruler/";
  appcast = "https://github.com/pascalpp/FreeRuler/releases";
};

GIMP = self.installApplication rec {
  name = "GIMP";
  majorMinorVersion = "2.10";
  version = "${majorMinorVersion}.14";
  sourceRoot = "GIMP-${majorMinorVersion}.app";
  src = super.fetchurl {
    url = "https://download.gimp.org/pub/gimp/v${majorMinorVersion}/osx/gimp-${version}-x86_64.dmg";
    sha256 = "0cm63vrmrksm7jq1yrxr16wry45yfqx23hqv5363hb04l4wiwqv0";
  };
  description = "The Free & Open Source Image Editor";
  homepage = "https://www.gimp.org";
  appcast = "https://download.gimp.org/pub/gimp/v#{majorMinorVersion}/osx/";
};

GoogleChrome = self.installApplication rec {
  name = "GoogleChrome";
  appname = "Google Chrome";
  version = "81.0.4044.138";
  sourceRoot = "Google Chrome.app";
  src = super.fetchurl {
    url = "https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg";
    # https://www.slimjet.com/chrome/google-chrome-old-version.php
    sha256 = "1npjsgwcva0yyp4jaq3mx9ixf4kx25wpx01cdjf3k0nzjn340w5q";
  };
  description = "The Google Chrome browser";
  homepage = "https://www.google.com/chrome/";
  appcast = "https://omahaproxy.appspot.com/history?os=mac;channel=stable";
};

Insomnia = self.installApplication rec {
  name = "Insomnia";
  version = "7.1.1";
  sourceRoot = "Insomnia.app";
  src = super.fetchurl {
    name = "insomnia-${version}.dmg";
    url = "https://github.com/getinsomnia/insomnia/releases/download/v${version}/Insomnia-${version}.dmg";
    sha256 = "7718dd2c1a6ec0edafe36116d9123cda80b769abadc2d4fc5c5389922c7dfa6f";
  };
  description = "Cross-platform HTTP and GraphQL Client";
  homepage = https://insomnia.rest;
};

IntelliJIDEA = self.installApplication rec {
  name = "IntelliJIDEA";
  appname = "IntelliJ IDEA";
  version = "2020.1.2";
  sourceRoot = "IntelliJ IDEA.app";
  src = super.fetchurl {
    url = "https://download.jetbrains.com/idea/ideaIU-${version}.dmg";
    sha256 = "1s4pa49rgmsrnfir19ym802s5is9s53dvxnddn08nz5n12vwh7sx";
  };
  description = "The most intelligent JVM IDE";
  homepage = https://www.jetbrains.com/idea/;
  appcast = https://www.jetbrains.com/idea/download/other.html;
};

TibcoJaspersoftStudio = self.installApplication rec {
  name = "TibcoJaspersoftStudio";
  version = "6.12.2";
  appname = "Tibco Jaspersoft Studio";
  sourceRoot = "TIBCO Jaspersoft Studio ${version}.app";
  src = super.fetchurl {
    url = "https://downloads.sourceforge.net/jasperstudio/JaspersoftStudio-${version}/TIB_js-studiocomm_${version}_macosx_x86_64.dmg";
    sha256 = "0agn36cm57n0nmm6zzqfjh9slxyiwg01la0fjggvijxhwipk7fpd";
  };
  description = "The Eclipse-based report development tool for JasperReports and JasperReports Server";
  homepage = https://community.jaspersoft.com/project/jaspersoft-studio;
  appcast = https://sourceforge.net/projects/jasperstudio/rss;
};

Zotero = self.installApplication rec {
  name = "Zotero";
  version = "5.0.84";
  sourceRoot = "Zotero.app";
  src = super.fetchurl {
    name = "zotero-${version}.dmg";
    url = "https://download.zotero.org/client/release/${version}/Zotero-${version}.dmg";
    sha256 = "0nfgbbwls576hi0bvjb47b5sn65ygxj3vz102s1jsvmk4pkwvap8";
  };
  description = ''
    Zotero is a free, easy-to-use tool to help you collect, organize, cite,
    and share your research sources
  '';
  homepage = https://www.zotero.org;
};

}
