{ stdenvNoCC, lib, fetchFromGitHub, makeWrapper, grub2_efi, grub2, dosfstools, dialog, ntfs3g, p7zip }:

stdenvNoCC.mkDerivation rec {
  pname = "mkwin";
  version = "0.1.7";

  src = fetchFromGitHub {
    owner = "lilyinstarlight";
    repo = pname;
    rev = "v${version}";
    sha256 = "1bfffhvr5iy8zinik8mp05rk2mqknwg80wl051q075c9a48rcxwd";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    make PREFIX=$out install
  '';

  fixupPhase = ''
    wrapProgram "$out/bin/mkwin" \
      --set MKWIN_GRUB grub \
      --set MKWIN_GRUB_EFI ${grub2_efi}/bin/grub-install \
      --set MKWIN_GRUB_PC ${grub2}/bin/grub-install \
      --prefix PATH : ${dosfstools}/bin:${dialog}/bin:${ntfs3g}/bin:${p7zip}/bin
  '';

  meta = with lib; {
    description = "A shell script to create a Windows installation USB from ISO";
    homepage = "https://github.com/lilyinstarlight/mkwin";
    license = licenses.mit;
  };
}
