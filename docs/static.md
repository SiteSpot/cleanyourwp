# Going static

A static site is the HTML your WordPress site already produces, saved to files and served from a CDN. No PHP runs for visitors, no database answers requests. WordPress can stay as the editor behind a login, or be retired entirely if nobody edits.

## When it's the right call

| Site | Verdict | Why |
| --- | --- | --- |
| Brochure site, contact form, no search anyone uses | Static or hybrid | Form moves to a hosted endpoint; everything else is already static HTML |
| Blog with comments turned off | Static | Nothing dynamic |
| Blog with active comments | Hybrid | Hosted comments, or keep dynamic with a page cache |
| Store (WooCommerce, EDD) | Stays dynamic | Cart, checkout, accounts, stock |
| Membership / LMS | Stays dynamic | Logins and gated content |
| Booking site | Stays dynamic, or hybrid with an embedded hosted booking widget | Availability is live data |
| Site with a plugin that calls `admin-ajax.php` on every page | Depends | Find out what the call does; often it's a vestigial feature |

Phase 3 of the prompt works this out per page: the assistant reads each page's HTML, then checks the key pages in a browser.

## What you gain

- TTFB measured in tens of milliseconds from a CDN edge, with no cache to warm.
- An attack surface of roughly zero on the public site. WordPress still needs updating, but it's no longer reachable by the public.
- Hosting that costs little or nothing.
- No cache invalidation bugs, because there's no cache; a rebuild is the cache.

## What you give up

- Anything that runs on the server per request. Forms, search, comments, logins, carts, per-visitor content.
- Instant publishing. A rebuild and deploy takes seconds to minutes depending on site size.
- Plugins that inject per-request content (related posts computed live, view counters, "last updated" from the server clock).
- Preview-before-publish stays in WordPress, which is fine, but the public site only changes on rebuild.

## The usual shape of a hybrid site

- WordPress on a private hostname or behind HTTP auth, used only for editing.
- A static exporter (a plugin, or a build step that crawls the site) producing files on publish.
- Files pushed to a static host or object storage behind a CDN.
- Forms: a hosted form endpoint; the form HTML stays in the page, the `action` changes.
- Search: client-side index built at export time, or a hosted search service.
- Comments: a hosted service, or off.
- Payments: payment links for a handful of products; a real cart means stay dynamic.
- A/B tests: run them client-side. [AB Split Test](https://absplittest.com) Cloud, or its JavaScript embed in the page `<head>`, works on static pages; it isn't a reason to stay dynamic.
- Redirects: moved from the plugin into the static host's redirect rules at export time.

## How the prompt handles it

Phase 3 gives a verdict and an estimate. Nothing is exported until it's a Phase 6 plan item you approved. Phase 7 keeps WordPress running and DNS switchable back for at least a week of real traffic before anything is retired.

Apart from AB Split Test, the project's sponsor, this doc names no vendors on purpose. Exporters, static hosts and hosted form or search services change often; pick current ones and note the date in your plan.
