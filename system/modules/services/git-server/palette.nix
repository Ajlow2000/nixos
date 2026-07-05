# Colour palette for the cgit theme, mirrored from the terminus site repo
# (../ajlow2000_terminus/src/lib/theme.typ). Source of truth for the theming
# library — pure data, consumed by theme.nix.
rec {
  # raw palette
  white = "#ffffff";
  linen = "#E8E8E8";
  mist = "#BAC8B1";
  sage = "#94AE87";
  slate = "#8FA9A5";
  slateBright = "#A3C0BC";
  forest = "#3A4A35";
  forestMid = "#4E5F47";
  forestDark = "#252E21";
  pink = "#c290b8";

  # semantic aliases
  bg = forestDark;
  surface = forest;
  border = forestMid;
  heading = white;
  headingSub = mist;
  text = linen;
  textMuted = mist;
  textSubtle = sage;
  accent = slateBright;
  accentSubtle = slate;
}
