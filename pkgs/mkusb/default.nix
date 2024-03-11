{ lib
, stdenvNoCC
, fetchFromGitHub
, makeWrapper
, grub2_efi
, grub2
, dosfstools
, dialog
, syslinux
, gitUpdater
}:

stdenvNoCC.mkDerivation rec {
  pname = "mkusb";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "lilyinstarlight";
    repo = "mkusb";
    rev = "v${version}";
    hash = "sha256-TyL1TCJ/Z/Ko1b0GJdhoLvBbqHhFDpY49rQxDBX0zjw=";
  };

  strictDeps = true;

  nativeBuildInputs = [ makeWrapper ];

  dontConfigure = true;
  dontBuild = true;
  doInstallCheck = true;

  installPhase = ''
    make PREFIX=$out install

    wrapProgram $out/bin/mkusb \
      --set MKUSB_GRUB grub \
      --set MKUSB_GRUB_EFI ${grub2_efi}/bin/grub-install \
      --set MKUSB_GRUB_PC ${grub2}/bin/grub-install \
      --set MKUSB_MEMDISK ${syslinux}/share/syslinux/memdisk \
      --prefix PATH : ${dosfstools}/bin:${dialog}/bin
  '';

  installCheckPhase = "$out/bin/mkusb --help";

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };

  meta = with lib; {
    description = "A shell script to create ISO multiboot USB flash drives that support both legacy and EFI boot";
    homepage = "https://github.com/lilyinstarlight/mkusb";
    license = licenses.mit;
    maintainers = with maintainers; [ lilyinstarlight ];
    platforms = [ "x86_64-linux" "i686-linux" "aarch64-linux" ];
    mainProgram = "mkusb";
  };
}
