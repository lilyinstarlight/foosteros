{ stdenvNoCC, lib, fetchFromGitHub, makeWrapper, grub2_efi, grub2, dosfstools, dialog, syslinux }:

stdenvNoCC.mkDerivation rec {
  pname = "mkusb";
  version = "0.2.7";

  src = fetchFromGitHub {
    owner = "lilyinstarlight";
    repo = pname;
    rev = "v${version}";
    sha256 = "0zgk2znyb42x5csb9wgvngr84sx7a7l4v4mkhv3hpk200yfv1l6j";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    make PREFIX=$out install
  '';

  fixupPhase = ''
    wrapProgram "$out/bin/mkusb" \
      --set MKUSB_GRUB grub \
      --set MKUSB_GRUB_EFI ${grub2_efi}/bin/grub-install \
      --set MKUSB_GRUB_PC ${grub2}/bin/grub-install \
      --set MKUSB_MEMDISK ${syslinux}/share/syslinux/memdisk \
      --prefix PATH : ${dosfstools}/bin:${dialog}/bin
  '';

  meta = with lib; {
    description = "A shell script to create ISO multiboot USB flash drives that support both legacy and EFI boot";
    homepage = "https://github.com/lilyinstarlight/mkusb";
    license = licenses.mit;
  };
}
