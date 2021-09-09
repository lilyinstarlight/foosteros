{ lib, beamPackages, overrides ? (x: y: {}) }:

let
  buildRebar3 = lib.makeOverridable beamPackages.buildRebar3;
  buildMix = lib.makeOverridable beamPackages.buildMix;
  buildErlangMk = lib.makeOverridable beamPackages.buildErlangMk;

  self = packages // (overrides self packages);

  packages = with beamPackages; with self; {
    rustler = buildMix rec {
      name = "rustler";
      version = "0.22.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "17dl24cgcgmw7sfy0qah7hvxawwpqp9hf7j8pq4yrsqisnfrix81";
      };

      beamDeps = [ toml ];
    };

    toml = buildMix rec {
      name = "toml";
      version = "0.5.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "01qafnclxnb9dd650h8i020p5ig70l78rlgs2p811d8zyyzdmqzi";
      };

      beamDeps = [];
    };
  };
in self

