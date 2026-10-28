# svg-upload

**Replaces:** nothing. Keep a maintained SVG sanitizer when SVG uploads are needed.

**Covers:** guidance only; no upload-enabling PHP snippet is provided.

**Doesn't cover:** sanitizing SVGs. SVG files can contain active content. A MIME allowlist and an administrator capability check do not sanitize a file or protect subsequent viewers.

The previous `cywp-svg-upload.php` example enabled unsanitized SVG uploads and has been removed. If already installed, remove that mu-plugin as an approved site change and review existing SVG assets separately; removing the enabler does not clean files already uploaded. Do not replace a sanitization plugin with a short MIME-enabling snippet, even when only administrators upload media.

**Tested on:** not applicable; documentation only. Validate the chosen sanitizer and upload workflow on staging.
