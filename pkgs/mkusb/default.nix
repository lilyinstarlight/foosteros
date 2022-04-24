{ stdenvNoCC, lib, fetchFromGitHub, makeWrapper, grub2_efi, grub2, dosfstools, dialog, syslinux, runCommand }:

let mkusb =
stdenvNoCC.mkDerivation rec {
  pname = "mkusb";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "lilyinstarlight";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-TyL1TCJ/Z/Ko1b0GJdhoLvBbqHhFDpY49rQxDBX0zjw=";
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

  passthru.tests = {
    # test to make sure executable runs
    help = runCommand "${mkusb.name}-help-test" {} ''
      ${mkusb}/bin/mkusb --help >$out
    '';
  };

  meta = with lib; {
    description = "A shell script to create ISO multiboot USB flash drives that support both legacy and EFI boot";
    homepage = "https://github.com/lilyinstarlight/mkusb";
    license = licenses.mit;
    maintainers = with maintainers; [ lilyinstarlight ];
    platforms = [ "x86_64-linux" "i686-linux" ];
  };
}
; in mkusb
