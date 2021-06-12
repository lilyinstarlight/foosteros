{ buildVimPluginFrom2Nix }:

self: super: {
  vim-radical = super.vim-radical.overrideAttrs (old: {
    dependencies = with self; [ vim-magnum ];
  });
}
