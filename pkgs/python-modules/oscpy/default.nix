{ lib, buildPythonPackage, fetchPypi, runCommand, python3, python3Packages }:

buildPythonPackage rec {
  pname = "oscpy";
  version = "0.6.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-ByilpyZnMsnWRjAGPThJEdXWrkdEFrebeNSQV3P7bTM=";
  };

  pythonImportsCheck = [ "oscpy" ];

  meta = with lib; {
    description = "A modern implementation of OSC for Python 2/3";
    homepage = "https://github.com/kivy/oscpy";
    license = licenses.mit;
  };
}
