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
  forestDim = "#34422F"; # a touch darker than forest; used for list striping
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

  # syntax highlighting: terminus "lackluster" dark colours, but tuned for the
  # surface-green code background (its darkest tokens are lifted so they read
  # against #3A4A35 instead of the near-black they were designed for).
  syntax = {
    fg = linen; # default text (lackluster #DDDDDD)
    comment = "#8A9487"; # lifted from #3A3A3A
    keyword = "#B3BBAF"; # lifted from #666666
    string = slateBright; # lackluster slate #708090, lifted toward accent
    escape = "#9FC29F"; # lackluster #789978, lifted
    func = "#DEEEED"; # kept
    type = "#C3C9BE"; # lackluster #AAAAAA, lifted
    number = "#C3C9BE"; # lackluster #AAAAAA, lifted
    tag = "#AEB6AA"; # lifted from #555555
    attr = "#AEB6AA"; # lifted from #444444
    variable = "#D6D6D6"; # lackluster #CCCCCC
    punctuation = "#A6ADA0"; # lifted from #7A7A7A
  };

  # diffs (palette has no red/green pair, so introduce a tuned one)
  diffAddFg = "#A9D492";
  diffAddBg = "#2B3A24";
  diffDelFg = "#D79C9C";
  diffDelBg = "#3B2626";
}
