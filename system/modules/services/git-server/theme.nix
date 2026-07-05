# cgit chrome theme, generated from the palette. Injected via cgit's
# head-include as an inline <style>; cgit emits its own stylesheet <link>
# first, so reusing cgit's own `div#cgit ...` selectors here wins by source
# order (equal specificity).
#
# Scope: chrome only. Code/diff views are deliberately kept light so the
# (light-background) pygments syntax colours stay legible until the dedicated
# dark code/diff pass.
palette:
''
  /* base */
  html, body { background: ${palette.bg}; }
  div#cgit { color: ${palette.text}; background: ${palette.bg}; }
  div#cgit a { color: ${palette.accent}; }
  div#cgit a:hover { color: ${palette.accentSubtle}; }

  /* header */
  div#cgit table#header td.logo { text-align: center; vertical-align: middle; }
  div#cgit table#header td.logo img { height: 55px; width: auto; }
  div#cgit table#header td.main a { color: ${palette.heading}; }
  div#cgit table#header td.sub {
    color: ${palette.textSubtle};
    border-top: solid 1px ${palette.border};
    border-bottom: solid 3px ${palette.border};
  }

  /* tabs */
  div#cgit table.tabs { border-bottom: solid 3px ${palette.border}; }
  div#cgit table.tabs td a { color: ${palette.textMuted}; }
  div#cgit table.tabs td a.active { color: ${palette.heading}; background-color: ${palette.surface}; }

  /* path bar + content divider */
  div#cgit div.path { color: ${palette.text}; background-color: ${palette.surface}; }
  div#cgit div.content { border-bottom: solid 3px ${palette.border}; }

  /* repo/log lists */
  /* distinct header band, lighter than both alternating row colours */
  div#cgit table.list th { color: ${palette.heading}; background-color: ${palette.border}; }
  div#cgit table.list tr.logheader { background-color: ${palette.border}; }
  div#cgit table.list tr:nth-child(even) { background: ${palette.forestDim}; }
  div#cgit table.list tr:nth-child(odd) { background: ${palette.bg}; }
  div#cgit table.list tr:hover { background: ${palette.surface}; }
  div#cgit table.list tr.nohover,
  div#cgit table.list tr.nohover:hover { background: ${palette.bg}; }
  div#cgit table.list td a { color: ${palette.accent}; }
  div#cgit table.list td a.ls-dir { color: ${palette.accent}; font-weight: bold; }
  div#cgit table.list td a:hover { color: ${palette.accentSubtle}; }

  /* commit/summary panels */
  div#cgit table.commit-info th,
  div#cgit div.cgit-panel th,
  div#cgit table#downloads th { color: ${palette.heading}; background-color: ${palette.surface}; }
  div#cgit div.cgit-panel { border: solid 1px ${palette.border}; background: ${palette.bg}; }

  /* form inputs */
  div#cgit td#sidebar input.txt,
  div#cgit table#header td.form input,
  div#cgit table#header td.form select {
    color: ${palette.text};
    background: ${palette.bg};
    border: solid 1px ${palette.border};
  }

  /* keep code/diff readable (light) until the dark code/diff pass */
  div#cgit div#blob,
  div#cgit table.blob,
  div#cgit table.blob pre,
  div#cgit table.diff,
  div#cgit table.diff td { background: #fff; color: #333; }

  /* HTTP clone URL is anonymous read-only; SSH is the RW path */
  div#cgit a[rel='vcs-git'][href^='http://']::after { content: ' (read only)'; color: ${palette.textSubtle}; }
''
