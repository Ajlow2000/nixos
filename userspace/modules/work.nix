{
  config,
  pkgs,
  inputs,
  ...
}:
let
  terminal-rain-lightning = pkgs.python3Packages.buildPythonApplication {
    pname = "terminal-rain-lightning";
    version = "0.1.0";
    pyproject = true;

    src = pkgs.fetchFromGitHub {
      owner = "rmaake1";
      repo = "terminal-rain-lightning";
      rev = "cc3aa19e1e9aec628a608b0ca6b7c475cce98c05";
      hash = "sha256-GJvGnvo78l4RK2Y9ACbqOXHLQkNtIwIktbm/FK1vOcc=";
    };

    build-system = [ pkgs.python3Packages.setuptools ];

    meta = with pkgs.lib; {
      description = "Terminal rain and lightning animation using Python and curses";
      homepage = "https://github.com/rmaake1/terminal-rain-lightning";
      license = licenses.mit;
      mainProgram = "terminal-rain";
    };
  };
in
{
  home.packages = [ terminal-rain-lightning ];
}
