self: super: {
  jetbrains = super.jetbrains // {
    jdk = super.stdenv.mkDerivation rec {
      pname = "jetbrainsjdk";
      version = "702.1";
      darwinVersion = "11_0_6-osx-x64-b${version}";

      src = super.fetchurl {
        url =
          "https://bintray.com/jetbrains/intellij-jbr/download_file?file_path=jbrsdk-${darwinVersion}.tar.gz";
        sha256 = "1ra33mp71awhmzf735dq7hxmx9gffsqj9cdp51k5xdmnmb66g12s";
      };

      nativeBuildInputs = [ super.file ];
      unpackCmd = "mkdir jdk; pushd jdk; tar -xzf $src; popd";
      installPhase = ''
        cd ..;
        mv $sourceRoot/jbrsdk $out;
      '';

      passthru.home = "${self.jetbrains.jdk}/Contents/Home";

      description = "An OpenJDK fork to better support Jetbrains's products.";
      longDescription = ''
        JetBrains Runtime is a runtime environment for running IntelliJ Platform
        based products on Windows, Mac OS X, and Linux. JetBrains Runtime is
        based on OpenJDK project with some modifications. These modifications
        include: Subpixel Anti-Aliasing, enhanced font rendering on Linux, HiDPI
        support, ligatures, some fixes for native crashes not presented in
        official build, and other small enhancements.

        JetBrains Runtime is not a certified build of OpenJDK. Please, use at
        your own risk.
      '';

      meta = with super.lib; {
        homepage = "https://bintray.com/jetbrains/intellij-jdk/";
        documentation =
          "https://confluence.jetbrains.com/display/JBR/JetBrains+Runtime";
        license = licenses.gpl2;
        maintainers = with maintainers; [ edwtjo ];
        platforms = with platforms; [ "x86_64-linux" "x86_64-darwin" ];
      };
    };
    # idea-ultimate = super.jetbrains.idea-ultimate.overrideAttrs (_: {
    #   name = "idea-ultimate";
    #   src = super.fetchurl {
    #     url = "https://download.jetbrains.com/idea/ideaIU-2019.3.3-no-jbr.tar.gz";
    #	sha256 = "b6ef08b34e38b9d1f637b4179b5c145375f1604208e42e4a605711e368c18a0c";
    #   };
    # });
  };
}
