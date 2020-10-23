{ stdenv, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "oscpy";
  version = "0.5.0";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "d2b5255c7c6349bc1bd1e59e08cd12acbbd63ce649f2588755783aa94dfb6b1a";
  };

  meta = with stdenv.lib; {
    description = "A modern implementation of OSC for python2/3";
    homepage = "https://github.com/kivy/oscpy";
    license = licenses.mit;
  };
}
