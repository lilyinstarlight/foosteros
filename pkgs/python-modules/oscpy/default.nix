{ pkgs, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "oscpy";
  version = "0.6.0";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "0cvdzdrmg46lg2dvf5j48ypddm8i94w3s1ih8vbcjck74sksaa07";
  };

  meta = with pkgs.lib; {
    description = "A modern implementation of OSC for python2/3";
    homepage = "https://github.com/kivy/oscpy";
    license = licenses.mit;
  };
}
