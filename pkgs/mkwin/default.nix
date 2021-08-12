{ stdenvNoCC, lib, fetchFromGitHub, makeWrapper, grub2_efi, grub2, dosfstools, dialog, ntfs3g, p7zip }:

stdenvNoCC.mkDerivation rec {
  pname = "mkwin";
  version = "0.1.8";

  src = fetchFromGitHub {
    owner = "lilyinstarlight";
    repo = pname;
    rev = "v${version}";
    sha256 = "015h8y0h8f04dvynv7sr5s9swizbbqf6amx5bi9clk6n29qrvamk";
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
    platforms = [ "x86_64-linux" "i686-linux" "aarch64-linux" "armv7l-linux" ];
  };
}
