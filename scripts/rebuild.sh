#!/usr/bin/env bash
# Original packaging code: GPL-2.0-or-later OR LGPL-2.1-or-later OR MPL-1.1.
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
if [ "$#" -ne 1 ] || [ -e "$1" ]; then
  echo "Usage: bash scripts/rebuild.sh /path/to/new-output-directory" >&2
  echo "The output directory must not already exist." >&2
  exit 1
fi
output_parent=$(dirname -- "$1")
mkdir -p -- "$output_parent"
output_dir=$(cd -- "$output_parent" && pwd)/$(basename -- "$1")
work_dir=$(mktemp -d)
trap 'rm -rf -- "$work_dir"' EXIT

(cd -- "$repo_dir" && sha256sum --check source/SHA256SUMS)
tar -xzf "$repo_dir/source/ckeditor4-4.22.1.tar.gz" -C "$work_dir"

# Set CKBUILDER_JAR to use a previously downloaded tool without network access.
if [ -n "${CKBUILDER_JAR:-}" ]; then
  cp -- "$CKBUILDER_JAR" "$work_dir/ckbuilder.jar"
else
  curl --fail --location --proto '=https' --tlsv1.2 \
    https://download.cksource.com/CKBuilder/2.4.3/ckbuilder.jar \
    --output "$work_dir/ckbuilder.jar"
fi
printf '%s  %s\n' \
  d664717cf110e22b139ba104b7d498c1bbbd7939607146e9ac8515a190b6d58a \
  "$work_dir/ckbuilder.jar" | sha256sum --check -

# Tested with Java 17. These exports let the legacy builder generate sprites.
java -Djava.awt.headless=true \
  --add-exports=java.desktop/sun.java2d=ALL-UNNAMED \
  --add-exports=java.desktop/sun.awt.image=ALL-UNNAMED \
  -jar "$work_dir/ckbuilder.jar" \
  --build "$work_dir/ckeditor4-4.22.1" "$output_dir" \
  --build-config "$repo_dir/build-config.js" \
  --version 4.22.1-custom.1 --revision 4a1fb11f44 \
  --no-zip --no-tar

# Restore upstream notice dates in generated headers; do not claim newer
# CKSource authorship merely because CKBuilder ran in a later calendar year.
python3 - "$output_dir/ckeditor" <<'PY'
from pathlib import Path
import re
import sys
root = Path(sys.argv[1])
pattern = re.compile(rb'(Copyright \(c\) 2003-)(\d{4})(, CKSource Holding sp\. z o\.o\.)')
for path in root.rglob('*'):
    if path.suffix not in {'.js', '.css'} or not path.is_file():
        continue
    data = path.read_bytes()
    # All matching upstream source notices are 2023 or earlier. Only undo
    # CKBuilder's forward dating, in the leading copyright comment.
    end = data.find(b'*/')
    if end < 0:
        continue
    header = pattern.sub(lambda m: m[1] + (b'2023' if int(m[2]) > 2023 else m[2]) + m[3], data[:end])
    if header != data[:end]:
        path.write_bytes(header + data[end:])

# Normalize generated config whitespace; keep upstream source files unmodified.
path = root / 'config.js'
path.write_text(path.read_text(encoding='utf-8-sig').rstrip() + '\n')
PY

test -f "$output_dir/ckeditor/ckeditor.js"
if grep -Eiq 'exportpdf|scayt|pdf-converter\.cke-cs\.com' "$output_dir/ckeditor/ckeditor.js"; then
  echo "Excluded plugin code was found in the output." >&2
  exit 1
fi
for name in exportpdf scayt codesnippetgeshi; do
  test ! -e "$output_dir/ckeditor/plugins/$name"
done
test ! -e "$output_dir/ckeditor/samples"

echo "Custom runtime built in $output_dir/ckeditor"
echo "The repository runtime has not been overwritten."
echo "Keep the source and build materials with package distributions."
echo "Hosted runtime points to https://github.com/zinctutors/ckeditor4-full-all"
echo "for source and build materials. Retain license/source notices."
