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
  div#cgit table#header td.main a { color: ${palette.text}; }
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
  div#cgit table.list th { color: ${palette.text}; background-color: ${palette.border}; }
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
  div#cgit table#downloads th { color: ${palette.text}; background-color: ${palette.surface}; }
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

  /* rendered README (About tab). No pygments stylesheet is loaded, so fenced
     code renders monochrome — safe to style dark. */
  div#cgit .markdown-body { color: ${palette.text}; }
  div#cgit .markdown-body h1,
  div#cgit .markdown-body h2,
  div#cgit .markdown-body h3,
  div#cgit .markdown-body h4,
  div#cgit .markdown-body h5,
  div#cgit .markdown-body h6 { color: ${palette.text}; }
  /* the toc extension wraps heading text in <a class="toclink">, and cgit's
     injected markdown stylesheet forces that black with an equal-specificity
     rule loaded after ours — !important is needed to win. */
  div#cgit .markdown-body h1 a.toclink,
  div#cgit .markdown-body h2 a.toclink,
  div#cgit .markdown-body h3 a.toclink,
  div#cgit .markdown-body h4 a.toclink,
  div#cgit .markdown-body h5 a.toclink,
  div#cgit .markdown-body h6 a.toclink { color: ${palette.text} !important; }
  div#cgit .markdown-body h1,
  div#cgit .markdown-body h2 { border-bottom: solid 1px ${palette.border}; padding-bottom: 0.2em; }
  div#cgit .markdown-body a { color: ${palette.accent}; }
  div#cgit .markdown-body code { background: ${palette.surface}; color: ${palette.text}; padding: 0.1em 0.3em; border-radius: 3px; }
  div#cgit .markdown-body pre,
  div#cgit .markdown-body .highlight { background: ${palette.surface}; color: ${palette.text}; padding: 0.6em 0.8em; border-radius: 4px; overflow-x: auto; }
  div#cgit .markdown-body pre code { background: none; padding: 0; }
  div#cgit .markdown-body blockquote { color: ${palette.textMuted}; border-left: solid 3px ${palette.border}; padding-left: 0.8em; margin-left: 0; }
  div#cgit .markdown-body table th { color: ${palette.text}; background: ${palette.border}; }
  div#cgit .markdown-body table tr { background: ${palette.surface}; }
  div#cgit .markdown-body table tr:nth-child(2n) { background: ${palette.forestDim}; }
  div#cgit .markdown-body table th,
  div#cgit .markdown-body table td { border: solid 1px ${palette.border}; padding: 0.2em 0.5em; }
  div#cgit .markdown-body hr { border: none; border-top: solid 1px ${palette.border}; }

  /* HTTP clone URL is anonymous read-only; SSH is the RW path */
  div#cgit a[rel='vcs-git'][href^='http://']::after { content: ' (read only)'; color: ${palette.textSubtle}; }
''
