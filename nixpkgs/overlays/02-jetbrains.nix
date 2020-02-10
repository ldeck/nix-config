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
    idea-ultimate = super.jetbrains.idea-ultimate.overrideAttrs (_: {
      name = "idea-ultimate.2019.3.2";
      src = super.fetchurl {
        url = "https://download.jetbrains.com/idea/ideaIU-2019.3.2-no-jbr.tar.gz";
	sha256 = "09lgdd7gkx94warjc7wah9w7s9lj81law8clavjjyjas8bhhf1hz";
      };
    });
  };
}