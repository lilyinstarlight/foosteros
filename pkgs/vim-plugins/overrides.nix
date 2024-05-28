{ buildVimPlugin, luaPackages, python3, gnused, writeText }:

self: super: {
  vim-radical = super.vim-radical.overrideAttrs (attrs: {
    dependencies = with self; [ vim-magnum ];
  });

  vim-resolve = super.vim-resolve.overrideAttrs (attrs: {
    postPatch = ''
      ${gnused}/bin/sed -i -e '1i import sys\nsys.path.append("${python3.pkgs.websocket-client}/${python3.sitePackages}")' rplugin/python3/resolveplugin.py
    '';
  });
}
