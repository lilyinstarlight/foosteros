{ pkgs, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "oscpy";
  version = "0.6.0";

  src = python3Packages.fetchPypi {
    inherit pname version;
    hash = "sha256-ByilpyZnMsnWRjAGPThJEdXWrkdEFrebeNSQV3P7bTM=";
  };

  meta = with pkgs.lib; {
    description = "A modern implementation of OSC for python2/3";
    homepage = "https://github.com/kivy/oscpy";
    license = licenses.mit;
  };
}
