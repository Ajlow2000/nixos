{ pkgs }:

# let
#     image = pkgs.fetchurl {
#         url = "https://github.com/Ajlow2000/wallpaper/blob/main/everforest-00.jpg";
#         sha256 = "1d4q41frfj7l3lw5lmyhygam0abz42w1yz4fgv5qwql12ha9jcdp";
#     };
# in
pkgs.stdenv.mkDerivation {
    name = "sddm-theme";
    src = pkgs.fetchFromGitHub {
        owner = "MarianArlt";
        repo = "sddm-sugar-dark";
        rev = "ceb2c455663429be03ba62d9f898c571650ef7fe";
        sha256 = "0153z1kylbhc9d12nxy9vpn0spxgrhgy36wy37pk6ysq7akaqlvy";
    };
    installPhase = ''
        mkdir -p $out
        cp -R ./* $out/
    '';
        # cd $out/
        # rm Background.jpg
        # cp -r ${image} $out/Background.jpg
}
