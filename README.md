# CKEditor 4.22.1 custom build

An independently maintained CKEditor 4.22.1 build with Vite integration,
packaged for installation with yarn or npm. This is derived from CKSource's
open-source release, not an official CKSource distribution or a byte-identical
copy of the CDN `full-all` build.

Copyright (c) 2003-2023, CKSource Holding sp. z o.o. All rights reserved.
CKEditor is a trademark of CKSource Holding sp. z o.o.

## Build contents

The compiled plugin selection follows CKSource's CDN full-all 4.22.1 build,
except that **Export to PDF and SCAYT are excluded entirely**. Their compiled
code and asset directories are absent. Optional open-source plugins from the
upstream source tree remain available. Samples and `codesnippetgeshi` are
excluded from runtime output. See `build-config.js` for the exact selection.

Export to PDF's commercial terms do not apply to this build because its code
is not included. SCAYT was also excluded so every shipped runtime component
comes from the accompanying upstream source tree. Other integrations, such as
Easy Image, may use external services with separate terms; no service access
or subscription is granted by this package.

The version is `4.22.1-custom.1` to distinguish this build from upstream.
This custom build is the repository's first version.

## Installing

Use a reviewed commit containing this custom build:

```json
"dependencies": {
  "ckeditor4": "github:zinctutors/ckeditor4-full-all#<custom-build-commit>"
}
```

Replace `<custom-build-commit>` with the actual commit after reviewing and
committing locally. The placeholder is not an installable Git reference.

## Using it with Vite

```js
// vite.config.js
import ckeditor from 'ckeditor4/vite';

export default { plugins: [ckeditor()] };
```

CKEditor loads plugins, skins, and language files relative to `ckeditor.js`.
The Vite plugin serves this folder under `<base>ckeditor/` during development
and emits it under `<outDir>/ckeditor/` during builds. `ckeditor.js` retains
the manifest entry `ckeditor/ckeditor.js`.

The output includes only runtime files, `LICENSE.md`, `legal.txt`, and a short
generated `SOURCE.txt` notice pointing to:
https://github.com/zinctutors/ckeditor4-full-all

The editable source archive in `source/`, `build-config.js`, and
`scripts/rebuild.sh` live in the GitHub repository, not in the Vite output.
The plugin does not serve repository documentation, `vite.mjs`, or `package.json`.
Retain the license/source notices and component notices when redistributing.

Keep the repo public and never rewrite its history, so the source for every shipped version stays available.

## Rebuilding

Requirements: Java 17, Python 3, Bash, tar, sha256sum, and curl. From the repository root:

```sh
bash scripts/rebuild.sh /tmp/ckeditor4-custom-build
```

Choose an output directory that does not already exist. The script checks the
bundled source and build configuration, downloads CKBuilder 2.4.3 over HTTPS,
checks its SHA-256, and builds a runtime in the output's `ckeditor/` directory.
It does not overwrite this repository. To use a previously downloaded builder:

```sh
CKBUILDER_JAR=/path/to/ckbuilder.jar bash scripts/rebuild.sh /tmp/ckeditor4-custom-build
```

The script restores CKSource's 2003-2023 dates in generated copyright headers
and normalizes config.js whitespace. The upstream source archive is unchanged.
The builder is an external build tool and is not redistributed in this package.
Its checksum is pinned; an upstream replacement is rejected. CKBuilder generates
a time-dependent cache timestamp and may vary optional skin sprite ordering,
so rebuilds need not be byte-identical.

The local `source/ckeditor4-4.22.1.tar.gz` contains the exact upstream editable
files except the test suite, which is not used by this release build. The build
configuration and scripts are supplied separately. See `SOURCE.txt` for provenance
and dated changes.

## Licence

This distribution elects MPL 1.1 compliance, as documented in `legal.txt`.
Recipients retain the upstream choice of GPL 2 or later, LGPL 2.1 or later,
or MPL 1.1 or later. Original packaging code is offered under the same choices.
Third-party components retain their respective licenses; `LICENSE.md` includes
the license texts and notices. Preserve existing copyright headers.

The corresponding editable source and build materials are available in the
GitHub repository. The Vite output includes a source notice linking to that
repository. Publish the matching source before shipping each runtime version.
Future changes to covered code must also be reflected in the repository source
and dated change notice. Removing plugins does not grant rights to third-party trademarks.

## Security status

CKEditor 4.22.1 is end-of-life. This build does not add upstream security fixes.
Removing components does not make it a security-maintained release. Review
upstream advisories before deployment:
https://github.com/ckeditor/ckeditor4/security/advisories

The previous repository documentation identified CVE-2024-43411 (version
notifications) and CVE-2024-24815 (full-page mode or permissive filtering) as
applicable to the retained code. Disable version checks with `versionCheck: false`
and avoid full-page mode and filters that allow `script` or `style` elements.
These settings are not a claim to address every vulnerability.
