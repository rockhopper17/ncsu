#!/usr/bin/env bash
#
# scan_extensions.sh
#
# Inventories every file extension found under a parent directory (recursively),
# with counts and total size per extension. Use this to decide which extensions
# are "source code" (keep) vs data/binary/output (exclude via .gitignore).
#
# Usage:
#   ./scan_extensions.sh /path/to/old/source
#
# Output: a table of extension, file count, total size -- sorted by total size
# descending, so the biggest space-hogs surface first.
#

set -euo pipefail

PARENT_DIR="${1:-.}"

if [[ ! -d "$PARENT_DIR" ]]; then
  echo "Error: '$PARENT_DIR' is not a directory."
  exit 1
fi

echo "=================================================================="
echo "Extension inventory for: $PARENT_DIR"
echo "=================================================================="
echo

# Collect: extension<TAB>size(bytes) for every file, skipping .git internals
TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT

find "$PARENT_DIR" -type f -not -path '*/.git/*' -print0 | while IFS= read -r -d '' f; do
  base=$(basename "$f")
  if [[ "$base" == *.* && "$base" != .* ]]; then
    ext="${base##*.}"
    ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
  else
    ext="(no extension)"
  fi
  size=$(stat -f%z "$f" 2>/dev/null || stat -c%s "$f" 2>/dev/null)
  printf '%s\t%s\n' "$ext" "$size"
done > "$TMPFILE"

# Aggregate by extension: count + total size
awk -F'\t' '
{
  count[$1]++
  total[$1] += $2
}
END {
  for (ext in count) {
    printf "%s\t%d\t%d\n", ext, count[ext], total[ext]
  }
}
' "$TMPFILE" | sort -t$'\t' -k3 -rn | while IFS=$'\t' read -r ext count total; do
  human=$(( total / 1024 / 1024 ))
  if (( human == 0 )); then
    human_str="$(( total / 1024 ))K"
  else
    human_str="${human}M"
  fi
  printf "  .%-20s  %6d files   %8s\n" "$ext" "$count" "$human_str"
done

echo
echo "=================================================================="
echo "Review the list above. Common SOURCE extensions to look for:"
echo "  c cpp cc cxx h hpp f f90 f77 for m py java sh pl r jl"
echo "Common DATA/BUILD/BINARY extensions to likely exclude:"
echo "  dat txt out log o obj exe dll so mexa64 mexw64 mat gz zip tar"
echo "  mp4 m4v mov avi png jpg pdf doc docx ppt pptx xls xlsx"
echo "(.txt and .m are ambiguous -- .m is often MATLAB source (keep),"
echo " .txt is often either notes/README (keep) or data dumps (exclude) --"
echo " inspect those two categories by hand.)"
echo "=================================================================="
