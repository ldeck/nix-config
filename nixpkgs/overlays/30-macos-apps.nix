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
  version = "2.2.0.4";
  revision = "43472";
  sourceRoot = "Docker.app";
  src = super.fetchurl {
    url = "https://download.docker.com/mac/stable/${revision}/Docker.dmg";
    sha256 = "defb095871ef260ccdb77d9960ed8510bdb288124025404f6543b94ec683e160";
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
  version = "74.0";
  sourceRoot = "Firefox.app";
  src = super.fetchurl {
    name = "Firefox-${version}.dmg";
    url = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/${version}/mac/en-US/Firefox+${version}.dmg";
    sha256 = "006qkc4bv65wf0iwc8qik0ismvdglp1s8k60scd29mgk1zd4z27i";
  };
  postInstall = ''
    mkdir -p $out/bin
    ln -fs $out/Applications/${name}.app/Contents/MacOS/firefox $out/bin/firefox
    ln -fs $out/Applications/${name}.app/Contents/MacOS/firefox-bin $out/bin/firefox-bin
  '';
  description = "The Firefox web browser";
  homepage = https://www.mozilla.org/en-US/firefox/;
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