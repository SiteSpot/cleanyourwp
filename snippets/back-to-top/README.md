# back-to-top

**Replaces:** back-to-top button plugins.

**Covers:** a fixed button in the bottom-right corner that scrolls to the top, with no JavaScript (uses an anchor to `#top` and CSS smooth scrolling), hidden on print.

**Doesn't cover:** fading in only after scrolling, custom icons, position settings. For fade-in, three lines of JS toggling a class on `window.scroll` does it.

**Tested on:** WordPress 6.9, block and classic themes, October 2026. Paste the HTML into the footer snippet (see header-footer-scripts) or your theme's footer template, and the CSS into Additional CSS.
