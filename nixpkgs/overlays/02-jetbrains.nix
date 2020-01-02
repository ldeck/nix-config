self: super:
{
  jetbrains = super.jetbrains // {
    jdk = super.jetbrains.jdk.overrideAttrs (oldAttrs: rec {
      version = "520.11";
      src = super.fetchurl {
        url = "https://bintray.com/jetbrains/intellij-jbr/download_file?file_path=jbrsdk-11_0_4-osx-x64-b520.11.tar.gz";
  	sha256 = "3fe1297133440a9056602d78d7987f9215139165bd7747b3303022a6f5e23834";
      };
      passthru = oldAttrs.passthru // {
        home = "${self.jetbrains.jdk}/Contents/Home";
      };
    });
    idea-ultimate = super.jetbrains.idea-ultimate.overrideAttrs (_: {
      name = "idea-ultimate.2019.2.4";
      src = super.fetchurl {
        url = "https://download.jetbrains.com/idea/ideaIU-2019.2.4-no-jbr.tar.gz";
	sha256 = "09mz4dx3zbnqw0vh4iqr8sn2s8mvgr7zvn4k7kqivsiv8f79g90a";
      };
    });
  };
}