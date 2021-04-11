{ stdenv, lib, fetchFromGitHub, bash, vagrant }:

stdenv.mkDerivation rec {
  name = "kapo=${version}";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "ebzzry";
    repo = "kapo";
    rev = "abd22b4860f83fe7469e8e40ee50f0db1c7a5f2c";
    sha256 =  "0jh0kdc7z8d632gwpvzclx1bbacpsr6brkphbil93vb654mk16ws";
  };

  buildPhase = ''
    substituteInPlace kapo --replace "/usr/bin/env bash" "${bash}/bin/bash"
    substituteInPlace kapo --replace "vagrant " "${vagrant}/bin/vagrant "
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp kapo $out/bin
    chmod +x $out/bin/kapo
  '';

  meta = with lib; {
    description = "Vagrant helper";
    homepage = https://github.com/ebzzry/kapo;
    license = licenses.cc0;
    maintainers = [ maintainers.ebzzry ];
    platforms = platforms.all;
  };
}
