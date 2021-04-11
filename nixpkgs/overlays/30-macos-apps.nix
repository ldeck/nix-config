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

installEclipseApplication =
  { name,
    appname ? name,
    version,
    src,
    description,
    homepage,
    postInstall ? "",
    sourceRoot ? ".",
    plistArrayArgs ? ''
      <string>-data</string>
      <string>${builtins.getEnv "HOME"}/.nix-data/${name}</string>
    '',
    ...
  }:
  self.installApplication {
    name = name;
    appname = appname;
    version = version;
    src = src;
    sourceRoot = sourceRoot;
    description = description;
    homepage = homepage;
    postInstall = postInstall + ''
      INFO=$out/Applications/${appname}.app/Contents/Info.plist
      substituteInPlace $INFO --replace "</array>" "${plistArrayArgs}</array>"
    '';
  };

Chromium = self.installApplication rec {
  name = "Chromium";
  version = "841414";
  sourceRoot = "chrome-mac/${name}.app";
  src = super.fetchurl {
    url = "https://commondatastorage.googleapis.com/chromium-browser-snapshots/Mac/${version}/chrome-mac.zip";
    sha256 = "11bn7finc76kamdrh61icvg35wfnpch3rpxpa0gigzwar3gfn7q2";
  };
  description = "Chromium is an open-source browser project that aims to build a safer, faster, and more stable way for all Internet users to experience the web.";
  homepage = "https://chromium.org/Home";
  appcast = "https://chromiumdash.appspot.com/releases?platform=Mac";
  #appcast = "https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Mac%2FLAST_CHANGE?alt=media";
};

Discord = self.installApplication rec {
  name = "Discord";
  version = "0.0.261";
  sourceRoot = "${name}.app";
  src = super.fetchurl {
    url = "https://dl.discordapp.net/apps/osx/${version}/Discord.dmg";
    sha256 = "f6bed5976d1ee223b42986b185626fbc758d5f918aff27d3d7b0c2212406cba9";
  };
  description = "Your place to talk. Whether you’re part of a school club, gaming group, worldwide art community, or just a handful of friends that want to spend time together, Discord makes it easy to talk every day and hang out more often.";
  appcast = https://discord.com/api/stable/updates?platform=osx;
  homepage = https://discord.com;
};

Docker = self.installApplication rec {
  name = "Docker";
  version = "3.2.2";
  revision = "61853";
  sourceRoot = "${name}.app";
  src = super.fetchurl {
    url = "https://desktop.docker.com/mac/stable/amd64/${revision}/${name}.dmg";
    sha256 = "0sxapv6n1adncdi69haadjdylb60h352ay7yq83xz83fyhwl0kf4";
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
  version = "87.0";
  sourceRoot = "Firefox.app";
  src = super.fetchurl {
    name = "Firefox-${version}.dmg";
    url = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/${version}/mac/en-US/Firefox+${version}.dmg";
    sha256 = "1cih6i2p53mchqqrw2wlqhfka59p5qm4a7d0zc9ism0gvq5zpiz2";
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
  version = "${majorMinorVersion}.22";
  sourceRoot = "GIMP-${majorMinorVersion}.app";
  src = super.fetchurl {
    url = "https://download.gimp.org/pub/gimp/v${majorMinorVersion}/osx/gimp-${version}-x86_64.dmg";
    sha256 = "102jm60bgnymm9xsdggg6bsfvqd3m81jxpy7q4j562cwmpw2nfwf";
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
  version = "88.0.4324.192";
  sourceRoot = "Google Chrome.app";
  src = super.fetchurl {
    url = "https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg";
    # https://www.slimjet.com/chrome/google-chrome-old-version.php
    sha256 = "14ijmp2k35fpjv8xff954vqs692kzxfakbb78y1flslc41xvwgmp";
  };
  description = "The Google Chrome browser";
  homepage = "https://www.google.com/chrome/";
  appcast = "https://omahaproxy.appspot.com/history?os=mac;channel=stable";
};

Insomnia = self.installApplication rec {
  name = "Insomnia";
  version = "2020.5.2";
  sourceRoot = "Insomnia.app";
  src = super.fetchurl {
    url = "https://github.com/Kong/insomnia/releases/download/core%40${version}/Insomnia.Core-${version}.dmg";
    sha256 = "1ll88ngfiavacx0pq96lpmshp99k1x5ypk00xnww53y81gila21h";
  };
  description = "Cross-platform HTTP and GraphQL Client";
  homepage = https://insomnia.rest;
  appcast = "https://api.insomnia.rest/changelog.json?app=com.insomnia.app";
};

InsomniaDesigner = self.installApplication rec {
  name = "InsomniaDesigner";
  appname = "Insomnia Designer";
  version = "2020.5.2";
  sourceRoot = "Insomnia Designer.app";
  src = super.fetchurl {
    url = "https://github.com/Kong/insomnia/releases/download/designer%40${version}/Insomnia.Designer-${version}.dmg";
    sha256 = "0w9kdn316rxkm02nqxw4xrhja5xgp3l0hmg2mmb3d4782l7h5kx9";
  };
  description = "The Collaborative API Design Tool for designing and managing OpenAPI specs.";
  homepage = https://insomnia.rest;
  appcast = "https://api.insomnia.rest/changelog.json?app=com.insomnia.designer";
};

IntelliJIDEA = self.installApplication rec {
  name = "IntelliJIDEA";
  appname = "IntelliJ IDEA";
  version = "2021.1";
  sourceRoot = "IntelliJ IDEA.app";
  src = super.fetchurl {
    url = "https://download.jetbrains.com/idea/ideaIU-${version}.dmg";
    sha256 = "15skgbj230pb928lkn5z3ymi8nnviwlnh82spk9zzjslc3pxvqbn";
  };
  description = "The most intelligent JVM IDE";
  homepage = https://www.jetbrains.com/idea/;
  appcast = https://www.jetbrains.com/idea/download/other.html;
};

JProfiler = self.installApplication rec {
  name = "JProfiler";
  version = "12.0.1";
  uversion = builtins.replaceStrings ["."] ["_"] "${version}";
  sourceRoot = "${name}.app";
  src = super.fetchurl rec {
    url = "https://download-gcdn.ej-technologies.com/jprofiler/jprofiler_macos_${uversion}.dmg";
    sha256 = "0pvz6rx2z9agpglnkzlfkinhlr9p9pg44v9cbdvcybgvgl3dqp67";
  };
  description = "The award-winning all-in-one java profiler";
  homepage = https://www.ej-technologies.com/products/jprofiler/overview.html;
  appcase = https://www.ej-technologies.com/feeds/jprofiler/;
};

MAT = self.installEclipseApplication rec {
  name = "MAT";
  majorMinorVersion = "1.11.0";
  version = "${majorMinorVersion}.20201202";
  sourceRoot = "mat.app";
  src = super.fetchurl {
    url = "https://www.eclipse.org/downloads/download.php?r=1&file=/mat/${majorMinorVersion}/rcp/MemoryAnalyzer-${version}-macosx.cocoa.x86_64.zip";
    sha256 = "0swi65v58n668zfzgyql8kfbpjhyrcq3hhpi637h18d5ba3xivg2";
  };
  description = "The Eclipse Memory Analyzer is a fast and feature-rich Java heap analyzer that helps you find memory leaks and reduce memory consumption.";
  homepage = "https://www.eclipse.org/mat/";
  appcast = "https://www.eclipse.org/mat/downloads.php";
};

Postman = self.installApplication rec {
  name = "Postman";
  version = "7.36.1";
  sourceRoot = "${name}.app";
  src = super.fetchurl {
    url = "https://dl.pstmn.io/download/version/${version}/osx64";
    sha256 = "1jcjs8xhv7ybh5ksf77h5x86f5blv8cypaba3k3xycxhy02ylwzk";
    name = "${name}-osx-${version}.zip";
  };
  description = "Collaboration platform for API development";
  homepage = "https://www.postman.com/";
  appcast = "https://macupdater.net/cgi-bin/check_urls/check_url_filename.cgi?url=https://dl.pstmn.io/download/latest/osx";
};

Signal = self.installApplication rec {
  name = "Signal";
  version = "1.39.4";
  sourceRoot = "${name}.app";
  src = super.fetchurl {
    url = "https://updates.signal.org/desktop/signal-desktop-mac-${version}.dmg";
    sha256 = "0di73h6hf8py18l1xgzh35lq1hpvm17lnavb9pan9w5wp29x35w6";
  };
  description = "Cross-platform instant messaging application focusing on security";
  homepage = "https://signal.org/";
  appcast = "https://github.com/signalapp/Signal-Desktop/releases.atom";
};

TibcoJaspersoftStudio = self.installApplication rec {
  name = "TibcoJaspersoftStudio";
  version = "6.16.0";
  appname = "Tibco Jaspersoft Studio";
  sourceRoot = "TIBCO Jaspersoft Studio ${version}.app";
  src = super.fetchurl {
    url = "https://downloads.sourceforge.net/jasperstudio/JaspersoftStudio-${version}/TIB_js-studiocomm_${version}_macosx_x86_64.dmg";
    sha256 = "0ph9680c404yicdly38vadri651wf3h0c882bg6j9i2aikw97x2w";
  };
  description = "The Eclipse-based report development tool for JasperReports and JasperReports Server";
  homepage = https://community.jaspersoft.com/project/jaspersoft-studio;
  appcast = https://sourceforge.net/projects/jasperstudio/rss;
};

Zotero = self.installApplication rec {
  name = "Zotero";
  version = "5.0.94";
  sourceRoot = "Zotero.app";
  src = super.fetchurl {
    name = "zotero-${version}.dmg";
    url = "https://download.zotero.org/client/release/${version}/Zotero-${version}.dmg";
    sha256 = "1chfgmx4mjbxqb7fwdmgy70kwm0z78w5x1vih85qf083byz7qclv";
  };
  description = ''
    Zotero is a free, easy-to-use tool to help you collect, organize, cite,
    and share your research sources
  '';
  homepage = https://www.zotero.org;
  appcast = https://www.zotero.org/download/;
};

}
