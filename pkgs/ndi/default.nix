{ requireFile, ndi }:

ndi.overrideAttrs (attrs: rec {
  fullVersion = "4.6.2";
  version = builtins.head (builtins.splitVersion fullVersion);

  src = requireFile rec {
    name = "InstallNDISDK_v${version}_Linux.tar.gz";
    sha256 = "181ypfj1bl0kljzrfr6037i14ykg2y4plkzdhym6m3z7kcrnm1fl";
    message = ''
      In order to use NDI SDK version ${fullVersion}, you need to comply with
      NewTek's license and download the appropriate Linux tarball from:

      ${attrs.meta.homepage}

      Once you have downloaded the file, please use the following command and
      re-run the installation:

      \$ nix-prefetch-url file://\$PWD/${name}
    '';
  };

  unpackPhase = ''
    unpackFile ${src}
    echo y | ./InstallNDISDK_v4_Linux.sh
    sourceRoot="NDI SDK for Linux";
  '';
})
