    self: super: {
        nix = super.nix.overrideAttrs (oa: {
          doCheck = false;
          doInstallCheck = false;
        });
    }
