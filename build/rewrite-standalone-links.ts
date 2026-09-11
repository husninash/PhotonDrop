import type { Plugin } from "vite";

// The header brand, byte-identical to the single line in send/index.html and
// receive/index.html — the inline SVG is what lets the standalone pages keep
// the logo with no external reference. A drift here fails the build (below).
const BRAND_INNER =
  '<svg class="brand-logo" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="3" fill="currentColor"/><path d="M12 2v3m0 14v3M2 12h3m14 0h3m-3.05-6.95l-2.12 2.12m-9.66 9.66l-2.12 2.12m13.9 0l-2.12-2.12M6.88 6.88L4.76 4.76"/><circle cx="12" cy="12" r="8" stroke-dasharray="2 4"/></svg>PhotonDrop';

/**
 * A standalone file has no siblings, so links to the other pages are dead ends.
 * Rewrites are exact-match and `required` ones throw when they miss, so editing
 * the markup breaks the build rather than silently shipping broken links.
 */
export function rewriteStandaloneLinks(page: "send" | "receive"): Plugin {
  const rules: { from: string; to: string; required: boolean }[] = [
    {
      // The Send/Receive switcher would be two dead links here; collapse it to
      // the badge naming the one mode this file is. The badge carries its own
      // catalog key so the standalone runtime translation reaches it too.
      from:
        '<nav class="mode-nav" aria-label="Mode" data-i18n-attr="aria-label:chrome.navAriaLabel">' +
        '<a href="../send/" data-i18n="chrome.navSend">Send</a>' +
        '<a href="../receive/" data-i18n="chrome.navReceive">Receive</a></nav>',
      to:
        page === "send"
          ? '<span class="mode-badge" data-i18n="chrome.modeBadgeSend">Send</span>'
          : '<span class="mode-badge" data-i18n="chrome.modeBadgeReceive">Receive</span>',
      required: true,
    },
    {
      from: `<a class="brand" href="../">${BRAND_INNER}</a>`,
      to: `<span class="brand">${BRAND_INNER}</span>`,
      required: true,
    },
    {
      from: "Open Receive on the other device.",
      to: "Open the standalone receiver on the other device.",
      required: false,
    },
    {
      // …and the catalog key with it, so the runtime translation says the
      // standalone wording rather than putting the hosted sentence back.
      from: 'data-i18n="send.footerHint"',
      to: 'data-i18n="send.footerHintStandalone"',
      required: false,
    },
    {
      // A single file has no siblings to load a favicon from, and leaving the
      // link in would be the one external reference in a page whose whole point
      // is having none.
      from: '<link rel="icon" href="../decimen_logo.svg" type="image/svg+xml" />',
      to: "",
      required: true,
    },
    {
      // Same rule for the home-screen icon: no siblings to load it from.
      from: '<link rel="apple-touch-icon" href="../apple-touch-icon.png" />',
      to: "",
      required: true,
    },
    {
      // Hosted-only: a downloaded artifact should not solicit. The JS-side
      // counterpart is the support.ts → support.inline.ts module swap.
      from:
        ' · <a class="support-link" href="https://buymeacoffee.com/bashalarmist" ' +
        'target="_blank" rel="noopener noreferrer" data-i18n="chrome.footerSupport">♥ support</a>',
      to: "",
      required: true,
    },
  ];
  return {
    name: "rewrite-standalone-links",
    transformIndexHtml(html) {
      for (const { from, to, required } of rules) {
        if (!html.includes(from)) {
          if (required) throw new Error(`standalone link rewrite missed its target: ${from}`);
          continue;
        }
        html = html.replaceAll(from, to);
      }
      return html;
    },
  };
}
