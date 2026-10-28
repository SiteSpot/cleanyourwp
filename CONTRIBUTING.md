# Contributing

Thanks. The most useful things you can add, in order:

## 1. A replacement snippet

A plugin you replaced with a small amount of code. One folder per snippet in `snippets/`:

```
snippets/sticky-header/
  README.md      what it replaces, what it covers, what it doesn't, tested on
  sticky-header.css
```

The README has four sections, kept short:

- **Replaces:** the plugin name(s) and the feature you used.
- **Covers:** what the snippet does.
- **Doesn't cover:** what the plugin did that this doesn't. Be honest; the next person decides from this.
- **Tested on:** WordPress version, PHP version, theme type (block or classic), date.

Rules for the code:

- Under about 30 lines. If it needs more, it probably deserves to stay a plugin.
- PHP goes in a must-use plugin file with a header comment. CSS goes in a `.css` file the person pastes into Appearance > Customize > Additional CSS or their child theme.
- No options pages, no settings, no external requests.
- Prefixed function names (`cywp_`).

## 2. A host note

One row in the table in `docs/hosts.md`: host, SSH, WP-CLI, PHP switching, backups, staging, anything that bit you. Date it.

## 3. An example run

An anonymised audit, labels, quiz, plan and report in `examples/<site-type>/`. Replace the domain with `example.com`, strip user names and emails, keep the structure. See `examples/brochure-site/` for the format.

## 4. Prompt wording

Pull requests to `PROMPT.md` are welcome. Keep the ground rules, approval protocol, backup protocol and stop conditions as they are, or make them stricter. Everything else can be tightened.

## Testing

Before opening a pull request:

- `bash tests/run.sh` passes. It runs `backup.sh` and `log.sh` against mocked WP-CLI and MySQL without contacting a site. The GitHub workflow also lints PHP syntax.
- Test the changed workflow on isolated staging before claiming live WordPress compatibility. State which runtime checks you actually ran; redact private data from output. Mock tests do not replace a real restore test.

## Through a coding agent

Point it at `AGENTS.md`. Same rules.
