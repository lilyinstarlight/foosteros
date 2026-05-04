{ lib, buildVimPlugin, python3, buildPackages, writeText }:

self: super: {
  vim-radical = super.vim-radical.overrideAttrs (old: {
    dependencies = with self; [ vim-magnum ];
  });

  vim-resolve = super.vim-resolve.overrideAttrs (old: {
    postPatch = ''
      ${buildPackages.gnused}/bin/sed -i -e '1i import sys\nsys.path.append("${python3.pkgs.websocket-client}/${python3.sitePackages}")' rplugin/python3/resolveplugin.py
    '';
  });
}
