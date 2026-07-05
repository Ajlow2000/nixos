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

  /* blob/source view */
  div#cgit div#blob,
  div#cgit table.blob,
  div#cgit table.blob pre { background: ${palette.surface}; color: ${palette.syntax.fg}; }
  div#cgit table.blob td.linenumbers,
  div#cgit table.blob td.linenumbers a { color: ${palette.textSubtle}; }
  div#cgit table.blob td.linenumbers a:hover { color: ${palette.accent}; }

  /* syntax tokens (Pygments classes). Scoped to .highlight so it themes both
     blob views and README fenced code. Colours from palette.syntax. */
  div#cgit .highlight { color: ${palette.syntax.fg}; }
  div#cgit .highlight .c, div#cgit .highlight .c1, div#cgit .highlight .cm,
  div#cgit .highlight .cs, div#cgit .highlight .cp { color: ${palette.syntax.comment}; font-style: italic; }
  div#cgit .highlight .k, div#cgit .highlight .kd, div#cgit .highlight .kn,
  div#cgit .highlight .kp, div#cgit .highlight .kr { color: ${palette.syntax.keyword}; }
  div#cgit .highlight .kt { color: ${palette.syntax.type}; }
  div#cgit .highlight .s, div#cgit .highlight .s1, div#cgit .highlight .s2,
  div#cgit .highlight .sb, div#cgit .highlight .sc, div#cgit .highlight .sh,
  div#cgit .highlight .si, div#cgit .highlight .sx, div#cgit .highlight .sr,
  div#cgit .highlight .ss, div#cgit .highlight .sd { color: ${palette.syntax.string}; }
  div#cgit .highlight .se { color: ${palette.syntax.escape}; }
  div#cgit .highlight .nf, div#cgit .highlight .fm,
  div#cgit .highlight .nb, div#cgit .highlight .bp { color: ${palette.syntax.func}; }
  div#cgit .highlight .nc, div#cgit .highlight .nn, div#cgit .highlight .no { color: ${palette.syntax.type}; }
  div#cgit .highlight .nt { color: ${palette.syntax.tag}; }
  div#cgit .highlight .na { color: ${palette.syntax.attr}; }
  div#cgit .highlight .nv, div#cgit .highlight .vc,
  div#cgit .highlight .vg, div#cgit .highlight .vi { color: ${palette.syntax.variable}; }
  div#cgit .highlight .m, div#cgit .highlight .mi, div#cgit .highlight .mf,
  div#cgit .highlight .mh, div#cgit .highlight .mo { color: ${palette.syntax.number}; }
  div#cgit .highlight .o, div#cgit .highlight .ow, div#cgit .highlight .p { color: ${palette.syntax.punctuation}; }

  /* diffs */
  div#cgit table.diff td div.head { color: ${palette.textMuted}; }
  div#cgit table.diff td div.hunk { color: ${palette.accent}; }
  div#cgit table.diff td div.add { color: ${palette.diffAddFg}; background: ${palette.diffAddBg}; }
  div#cgit table.diff td div.del { color: ${palette.diffDelFg}; background: ${palette.diffDelBg}; }
  div#cgit table.diffstat { background: ${palette.surface}; border: solid 1px ${palette.border}; }
  div#cgit table.diffstat td.add a { color: ${palette.diffAddFg}; }
  div#cgit table.diffstat td.del a { color: ${palette.diffDelFg}; }
  div#cgit table.diffstat td.upd a { color: ${palette.accent}; }
  div#cgit table.diffstat td.graph td.add { background-color: ${palette.diffAddFg}; }
  div#cgit table.diffstat td.graph td.rem { background-color: ${palette.diffDelFg}; }
  div#cgit span.insertions { color: ${palette.diffAddFg}; }
  div#cgit span.deletions { color: ${palette.diffDelFg}; }

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
