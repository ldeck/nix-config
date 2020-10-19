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
  version = "2.3.0.5";
  revision = "48029";
  sourceRoot = "Docker.app";
  src = super.fetchurl {
    url = "https://download.docker.com/mac/stable/${revision}/Docker.dmg";
    sha256 = "03ynkknn3v8s9nfhif39ivs1gdzpb29l9qj8n2znsc8zanc8sn2g";
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
    BINDIR="$out/Applications/${name}.app/Contents/Resources/bin"
    for f in `ls $BINDIR | grep docker`; do
      ln -fs "$BINDIR/$f" $out/bin/$f
    done
    #todo: add etc/docker[-compose].[bash|zsh]-completion
  '';
  };

Firefox = self.installApplication rec {
  name = "Firefox";
  version = "81.0.2";
  sourceRoot = "Firefox.app";
  src = super.fetchurl {
    name = "Firefox-${version}.dmg";
    url = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/${version}/mac/en-US/Firefox+${version}.dmg";
    sha256 = "1khzsnrk13z2lrwqd1vc6jm3qg7vmrgy996ss61ybfb6prjjj55s";
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

Gitter = self.installApplication rec {
  name = "Gitter";
  version = "1.177";
  sourceRoot = "Gitter.app";
  src = super.fetchurl {
    url = "https://update.gitter.im/osx/Gitter-${version}.dmg";
    sha256 = "0ca1c0d52c342548afbea8d3501282a4ccf494058aa2e23af27e09198a7a30a4";
  };
  description = "Gitter is a chat and networking platform that helps to manage, grow and connect communities through messaging, content and discovery.";
  homepage = "https://gitter.im";
  appcast = "https://update.gitter.im/osx/appcast.xml";
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
  version = "2020.3.3";
  sourceRoot = "Insomnia.app";
  src = super.fetchurl {
    url = "https://github.com/Kong/insomnia/releases/download/core%40${version}/Insomnia.Core-${version}.dmg";
    sha256 = "c22949f717ffaf8bdef10d0a833b1a9fe0eb2bebe317913db2e1ce7572fd5a44";
  };
  description = "Cross-platform HTTP and GraphQL Client";
  homepage = https://insomnia.rest;
  appcast = "https://api.insomnia.rest/changelog.json?app=com.insomnia.app";
};

InsomniaDesigner = self.installApplication rec {
  name = "InsomniaDesigner";
  appname = "Insomnia Designer";
  version = "2020.3.3";
  sourceRoot = "Insomnia Designer.app";
  src = super.fetchurl {
    url = "https://github.com/Kong/insomnia/releases/download/designer%40${version}/Insomnia.Designer-${version}.dmg";
    sha256 = "2bc0b19dda57ac4299a14c0e8e887c573415a1fa590be6bea93da5ed3c7af435";
  };
  description = "The Collaborative API Design Tool for designing and managing OpenAPI specs.";
  homepage = https://insomnia.rest;
  appcast = "https://api.insomnia.rest/changelog.json?app=com.insomnia.designer";
};

IntelliJIDEA = self.installApplication rec {
  name = "IntelliJIDEA";
  appname = "IntelliJ IDEA";
  version = "2020.2.3";
  sourceRoot = "IntelliJ IDEA.app";
  src = super.fetchurl {
    url = "https://download.jetbrains.com/idea/ideaIU-${version}.dmg";
    sha256 = "05nm7sg0gs4alyrk1cgk71dhr9p45v39raqld5vzp1mbgv515g5r";
  };
  description = "The most intelligent JVM IDE";
  homepage = https://www.jetbrains.com/idea/;
  appcast = https://www.jetbrains.com/idea/download/other.html;
};

MAT = self.installApplication rec {
  name = "MAT";
  majorMinorVersion = "1.10.0";
  version = "${majorMinorVersion}.20200225";
  sourceRoot = "mat.app";
  src = super.fetchurl {
    url = "https://www.eclipse.org/downloads/download.php?r=1&file=/mat/${majorMinorVersion}/rcp/MemoryAnalyzer-${version}-macosx.cocoa.x86_64.zip";
    sha256 = "dc711052e9ede8b6e9af0443035cee590bb5d2609705440f32d0ef0d6f66cbf3";
  };
  description = "The Eclipse Memory Analyzer is a fast and feature-rich Java heap analyzer that helps you find memory leaks and reduce memory consumption.";
  homepage = "https://www.eclipse.org/mat/";
  appcast = "https://www.eclipse.org/mat/downloads.php";
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
