{ buildVimPluginFrom2Nix, luaPackages }:

self: super: {
  vim-radical = super.vim-radical.overrideAttrs (attrs: {
    dependencies = with self; [ vim-magnum ];
  });
}
