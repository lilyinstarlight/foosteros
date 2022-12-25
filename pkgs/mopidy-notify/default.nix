{ lib, python3Packages, mopidy }:

python3Packages.buildPythonApplication rec {
  pname = "Mopidy-Notify";
  version = "0.2.0";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-lzZupjlS0kbNvsn18serOoMfu0sRb0nRwpowvOPvt/g=";
  };

  propagatedBuildInputs = [
    mopidy
    python3Packages.pydbus
  ];

  nativeBuildInputs = [
    python3Packages.pytestCheckHook
  ];

  pythonImportsCheck = [ "mopidy_notify" ];

  meta = with lib; {
    homepage = "https://github.com/phijor/mopidy-notify";
    description = "Mopidy extension for showing desktop notifications on track change";
    license = licenses.asl20;
    maintainers = with maintainers; [ lilyinstarlight ];
  };
}
