self: super:
{
  jetbrains = super.jetbrains // {
    jdk = super.jetbrains.jdk.overrideAttrs (oldAttrs: rec {
      version = "11_0_6-osx-x64-b702.1";
      src = super.fetchurl {
        url = "https://bintray.com/jetbrains/intellij-jbr/download_file?file_path=jbrsdk-${version}.tar.gz";
  	sha256 = "1ra33mp71awhmzf735dq7hxmx9gffsqj9cdp51k5xdmnmb66g12s";
      };
      passthru = oldAttrs.passthru // {
        home = "${self.jetbrains.jdk}/Contents/Home";
      };
    });
    # idea-ultimate = super.jetbrains.idea-ultimate.overrideAttrs (_: {
    #   name = "idea-ultimate";
    #   src = super.fetchurl {
    #     url = "https://download.jetbrains.com/idea/ideaIU-2019.3.3-no-jbr.tar.gz";
    # 	sha256 = "b6ef08b34e38b9d1f637b4179b5c145375f1604208e42e4a605711e368c18a0c";
    #   };
    # });
  };
}