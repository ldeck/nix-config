self: super: {
  # emscriptenVersion = "1.39.20";

  cairo = super.cairo.overrideAttrs(oa: rec {
    configureFlags = [
      "--enable-tee"
    ] ++ oa.configureFlags;
  });
}
