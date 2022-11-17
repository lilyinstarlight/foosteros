{ lib
, stdenv
, fetchFromGitHub
, fetchpatch
, callPackage
, buildGoModule
, installShellFiles
, symlinkJoin
, zlib
, sqlite
, cmake
, python3
, ninja
, perl
, autoconf
, automake
, libtool
, darwin
, cacert
, unzip
, go
, p11-kit
, makeTestPython
}:

let
  makeCurlImpersonate = { name, target }: stdenv.mkDerivation rec {
    pname = "curl-impersonate-${name}";
    version = "0.5.3";

    src = fetchFromGitHub {
      owner = "lwthiker";
      repo = "curl-impersonate";
      rev = "v${version}";
      hash = "sha256-5aRC9Ip86y4mw6WMve/e0ZWV23KxSBvwKkpaRQsUsOI=";
    };

    patches = [
      # Fix shebangs in the NSS build script
      # (can't just patchShebangs since makefile unpacks it)
      ./curl-impersonate-0.5.2-fix-shebangs.patch
      # Fixes issue with "--disable-static" on the configure script
      # lwthiker/curl-impersonate#117
      (fetchpatch {
        name = "curl-impersonate-fix-disable-static.patch";
        url = "https://github.com/lwthiker/curl-impersonate/commit/4a9c4027b8ad5e81b1be88a0f7c149eb754165eb.patch";
        hash = "sha256-OjaSgzoklzakCjzzXnnjk5a5WOvgWRajc43FDztcg4s=";
      })
    ];

    strictDeps = true;

    nativeBuildInputs = lib.optionals stdenv.isDarwin [
      # Must come first so that it shadows the 'libtool' command but leaves 'libtoolize'
      darwin.cctools
    ] ++ [
      installShellFiles
      cmake
      python3
      python3.pkgs.gyp
      ninja
      perl
      autoconf
      automake
      libtool
      unzip
      go
    ];

    buildInputs = [
      zlib
      sqlite
    ];

    configureFlags = [
      "--with-ca-bundle=${if stdenv.isDarwin then "/etc/ssl/cert.pem" else "/etc/ssl/certs/ca-certificates.crt"}"
      "--with-ca-path=${cacert}/etc/ssl/certs"
    ];

    buildFlags = [ "${target}-build" ];
    checkTarget = "${target}-checkbuild";
    installTargets = [ "${target}-install" ];

    doCheck = true;

    dontUseCmakeConfigure = true;
    dontUseNinjaBuild = true;
    dontUseNinjaInstall = true;
    dontUseNinjaCheck = true;

    postUnpack = lib.concatStringsSep "\n" (lib.mapAttrsToList (name: dep: "ln -sT ${dep.outPath} source/${name}") (lib.filterAttrs (n: v: v ? outPath) passthru.deps));

    preConfigure = ''
      export GOCACHE=$TMPDIR/go-cache
      export GOPATH=$TMPDIR/go
      export GOPROXY=file://${passthru.boringssl-go-modules}
      export GOSUMDB=off

      # Need to get value of $out for this flag
      configureFlagsArray+=("--with-libnssckbi=$out/lib")
    '';

    postInstall = ''
      # Remove vestigial *-config script
      rm $out/bin/curl-impersonate-${name}-config

      # Patch all shebangs of installed scripts
      patchShebangs $out/bin

      # Build and install completions for each curl binary

      # Patch in correct binary name and alias it to all scripts
      perl curl-*/scripts/completion.pl --curl $out/bin/curl-impersonate-${name} --shell zsh >$TMPDIR/curl-impersonate-${name}.zsh
      substituteInPlace $TMPDIR/curl-impersonate-${name}.zsh \
        --replace \
          '#compdef curl' \
          "#compdef curl-impersonate-${name}$(find $out/bin -name 'curl_*' -printf ' %f=curl-impersonate-${name}')"

      perl curl-*/scripts/completion.pl --curl $out/bin/curl-impersonate-${name} --shell fish >$TMPDIR/curl-impersonate-${name}.fish
      substituteInPlace $TMPDIR/curl-impersonate-${name}.fish \
        --replace \
          '--command curl' \
          "--command curl-impersonate-${name}$(find $out/bin -name 'curl_*' -printf ' --command %f')"

      # Install zsh and fish completions
      installShellCompletion $TMPDIR/curl-impersonate-${name}.{zsh,fish}
    '';

    preFixup = let
      libext = stdenv.hostPlatform.extensions.sharedLibrary;
    in ''
      # If libnssckbi.so is needed, link libnssckbi.so without needing nss in closure
      if grep -F nssckbi $out/lib/libcurl-impersonate-*${libext} &>/dev/null; then
        # NOTE: "p11-kit-trust" always ends in ".so" even when on darwin
        ln -s ${p11-kit}/lib/pkcs11/p11-kit-trust.so $out/lib/libnssckbi${libext}
        ${lib.optionalString stdenv.isLinux "patchelf --add-needed libnssckbi${libext} $out/lib/libcurl-impersonate-*${libext}"}
      fi
    '';

    disallowedReferences = [ go ];

    passthru = {
      deps = callPackage ./deps.nix {};

      boringssl-go-modules = (buildGoModule {
        inherit (passthru.deps."boringssl.zip") name;

        src = passthru.deps."boringssl.zip";
        vendorHash = "sha256-ISmRdumckvSu7hBXrjvs5ZApShDiGLdD3T5B0fJ1x2Q=";

        nativeBuildInputs = [ unzip ];

        proxyVendor = true;
      }).go-modules;
    };

    meta = with lib; {
      description = "A special build of curl that can impersonate Chrome & Firefox";
      homepage = "https://github.com/lwthiker/curl-impersonate";
      license = with licenses; [ curl mit ];
      maintainers = with maintainers; [ lilyinstarlight ];
      platforms = platforms.unix;
    };
  };
in

symlinkJoin rec {
  pname = "curl-impersonate";
  inherit (passthru.curl-impersonate-ff) version meta;

  name = "${pname}-${version}";

  paths = [
    passthru.curl-impersonate-ff
    passthru.curl-impersonate-chrome
  ];

  passthru = {
    curl-impersonate-ff = makeCurlImpersonate { name = "ff"; target = "firefox"; };
    curl-impersonate-chrome = makeCurlImpersonate { name = "chrome"; target = "chrome"; };

    updateScript = ./update.sh;

    inherit (passthru.curl-impersonate-ff) src;

    tests = lib.optionalAttrs stdenv.isLinux {
      curl-impersonate = import ./test.nix { inherit makeTestPython; };
    };
  };
}
