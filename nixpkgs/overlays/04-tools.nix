self: super: {
  emscriptenVersion = "1.39.20";


  lzfse = super.lzfse.overrideAttrs(oldAttrs: rec {
    meta = oldAttrs.meta // {
      platforms = with super.stdenv.lib; platforms.all;
    };
  });
}
