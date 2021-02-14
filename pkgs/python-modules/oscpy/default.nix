{ pkgs, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "oscpy";
  version = "0.5.0";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "22d4113accd9860e070a974ab8bbc024a9e4d2963a013e6b3a0699b6882ba421";
  };

  meta = with pkgs.lib; {
    description = "A modern implementation of OSC for python2/3";
    homepage = "https://github.com/kivy/oscpy";
    license = licenses.mit;
  };
}
