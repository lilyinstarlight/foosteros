{ pkgs }:

self: super: {
  vim-radical = super.vim-radical.overrideAttrs(old: {
    dependencies = with super; [ vim-magnum ];
  });
}
