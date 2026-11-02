import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = path.dirname(fileURLToPath(import.meta.url));
// Original packaging code: GPL-2.0-or-later OR LGPL-2.1-or-later OR MPL-1.1.
const ENTRIES = ['ckeditor.js', 'config.js', 'contents.css', 'styles.js', 'LICENSE.md', 'legal.txt', 'adapters', 'lang', 'plugins', 'skins', 'vendor'];
const TYPES = {
  '.css': 'text/css',
  '.gif': 'image/gif',
  '.html': 'text/html',
  '.jpg': 'image/jpeg',
  '.js': 'text/javascript',
  '.json': 'application/json',
  '.md': 'text/markdown',
  '.png': 'image/png',
  '.svg': 'image/svg+xml',
  '.txt': 'text/plain',
};

function files() {
  return ENTRIES.flatMap((entry) => {
    const full = path.join(ROOT, entry);
    if (!fs.statSync(full).isDirectory()) return [entry];

    return fs
      .readdirSync(full, { recursive: true, withFileTypes: true })
      .filter((dirent) => dirent.isFile())
      .map((dirent) => path.relative(ROOT, path.join(dirent.parentPath, dirent.name)).split(path.sep).join('/'));
  });
}

export default function ckeditor() {
  const sourceNotice = `CKEditor 4.22.1-custom.1 - independent build derived from CKSource's CKEditor 4.22.1.
Copyright (c) 2003-2023, CKSource Holding sp. z o.o. All rights reserved.
Covered source is available under MPL 1.1; recipients retain the upstream
GPL 2-or-later, LGPL 2.1-or-later, or MPL 1.1-or-later choices. See LICENSE.md.
2026-11-02, zinctutors: rebuilt without Export to PDF and SCAYT; omitted samples
and codesnippetgeshi; restored upstream notice dates in generated headers.
Corresponding editable source, build configuration, and rebuild instructions:
https://github.com/zinctutors/ckeditor4-full-all
Retain this notice and the license files when redistributing.
`;
  return {
    name: 'ckeditor4',

    configureServer(server) {
      server.middlewares.use(path.posix.join(server.config.base, 'ckeditor'), (req, res, next) => {
        if (req.url.split('?')[0] === '/SOURCE.txt') {
          res.setHeader('Content-Type', 'text/plain');
          res.end(sourceNotice);
          return;
        }
        const file = path.join(ROOT, decodeURIComponent(req.url.split('?')[0]));
        const servable = ENTRIES.includes(path.relative(ROOT, file).split(path.sep)[0]);
        if (!servable || !fs.statSync(file, { throwIfNoEntry: false })?.isFile()) return next();

        res.setHeader('Content-Type', TYPES[path.extname(file)] || 'application/octet-stream');
        fs.createReadStream(file).pipe(res);
      });
    },

    generateBundle() {
      this.emitFile({ type: 'asset', fileName: 'ckeditor/SOURCE.txt', source: sourceNotice });
      for (const name of files()) {
        const fileName = `ckeditor/${name}`;
        const source = fs.readFileSync(path.join(ROOT, name));
        const manifest = name === 'ckeditor.js' ? { name, originalFileName: fileName } : {};
        this.emitFile({ type: 'asset', fileName, source, ...manifest });
      }
    },
  };
}
