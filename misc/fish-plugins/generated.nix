# This file has been generated by ./misc/fish-plugins/update.py. Do not edit!
{ fetchFromGitHub }:

[
  {
    name = "done";
    src = fetchFromGitHub {
      owner = "franciscolourenco";
      repo = "done";
      rev = "37117c3d8ed6b820f6dc647418a274ebd1281832";
      sha256 = "1k95w2plb4jchqn0n84ickfkp3gan8k1l5xdcv1hkfgcvka0f9vi";
    };
  }

  {
    name = "humanize-duration";
    src = fetchFromGitHub {
      owner = "fishpkg";
      repo = "fish-humanize-duration";
      rev = "f7c7e9e0035ecdcbfdaae9dfc08505659db39cd3";
      sha256 = "078wzrppw62dz297860n2qdljnnpmhpaj60gw5cl4dbfcij24335";
    };
  }

]
