{ lib
, stdenvNoCC
, fetchFromGitHub
, makeWrapper
, grub2_efi
, grub2
, dosfstools
, dialog
, ntfs3g
, p7zip
, gitUpdater
}:

stdenvNoCC.mkDerivation rec {
  pname = "mkwin";
  version = "0.1.9";

  src = fetchFromGitHub {
    owner = "lilyinstarlight";
    repo = "mkwin";
    rev = "v${version}";
    hash = "sha256-WrxDlrHKW1gwXQVc7pKOtqMDEbXUSRAWWR2C8VEF70Q=";
  };

  strictDeps = true;

  nativeBuildInputs = [ makeWrapper ];

  dontConfigure = true;
  dontBuild = true;
  doInstallCheck = true;

  installPhase = ''
    make PREFIX=$out install

    wrapProgram $out/bin/mkwin \
      --set MKWIN_GRUB grub \
      --set MKWIN_GRUB_EFI ${grub2_efi}/bin/grub-install \
      --set MKWIN_GRUB_PC ${grub2}/bin/grub-install \
      --prefix PATH : ${dosfstools}/bin:${dialog}/bin:${ntfs3g}/bin:${p7zip}/bin
  '';

  installCheckPhase = "$out/bin/mkwin --help";

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };

  meta = with lib; {
    description = "A shell script to create a Windows installation USB from ISO";
    homepage = "https://github.com/lilyinstarlight/mkwin";
    license = licenses.mit;
    maintainers = with maintainers; [ lilyinstarlight ];
    platforms = [ "x86_64-linux" "i686-linux" "aarch64-linux" "armv7l-linux" ];
    mainProgram = "mkwin";
  };
}
