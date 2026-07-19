#!/usr/bin/env bash
#
# scan_ncsu_import.sh
#
# Scans a parent directory full of old project subdirectories and reports,
# for each one:
#   - whether it's a git repo (and what branch it's on)
#   - total size
#   - any individual files over a size threshold (candidates to exclude)
#
# This is a READ-ONLY report. It does not modify anything or touch GitHub.
# Use the output to decide, per-project, whether to:
#   (a) git subtree add it as-is
#   (b) clean it in a scratch clone first (drop big files, then subtree)
#   (c) just cp -r the current files (untracked dirs, or don't care about history)
#
# Usage:
#   ./scan_ncsu_import.sh /path/to/old/source [size_threshold_MB]
#
# Example:
#   ./scan_ncsu_import.sh ~/college_backup/src 5
#

set -euo pipefail

PARENT_DIR="${1:-}"
THRESHOLD_MB="${2:-5}"

if [[ -z "$PARENT_DIR" ]]; then
  echo "Usage: $0 /path/to/old/source [size_threshold_MB]"
  exit 1
fi

if [[ ! -d "$PARENT_DIR" ]]; then
  echo "Error: '$PARENT_DIR' is not a directory."
  exit 1
fi

THRESHOLD_BYTES=$(( THRESHOLD_MB * 1024 * 1024 ))

echo "=================================================================="
echo "Scanning: $PARENT_DIR"
echo "Large-file threshold: ${THRESHOLD_MB}MB"
echo "=================================================================="
echo

# Iterate over immediate subdirectories only
shopt -s nullglob
for dir in "$PARENT_DIR"/*/; do
  name=$(basename "$dir")
  echo "------------------------------------------------------------"
  echo "PROJECT: $name"
  echo "------------------------------------------------------------"

  # --- Git status ---
  if [[ -d "$dir/.git" ]]; then
    branch=$(git -C "$dir" branch --show-current 2>/dev/null || echo "?")
    if [[ -z "$branch" ]]; then
      # detached HEAD or old git version fallback
      branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "?")
    fi
    commit_count=$(git -C "$dir" rev-list --count HEAD 2>/dev/null || echo "?")
    echo "  Git: YES  (branch: $branch, commits: $commit_count)"
    echo "  -> plan: git subtree add --prefix=$name <path> $branch"
  else
    echo "  Git: NO (untracked)"
    echo "  -> plan: cp -r into new repo, then git add"
  fi

  # --- Total size ---
  total_size=$(du -sh "$dir" 2>/dev/null | cut -f1)
  echo "  Total size: $total_size"

  # --- Large files (current working tree, not history) ---
  echo "  Files over ${THRESHOLD_MB}MB:"
  found_large=0
  while IFS= read -r -d '' f; do
    size=$(stat -c%s "$f" 2>/dev/null || stat -f%z "$f")
    if (( size > THRESHOLD_BYTES )); then
      human=$(du -h "$f" | cut -f1)
      rel="${f#"$dir"}"
      echo "    - $rel  ($human)"
      found_large=1
    fi
  done < <(find "$dir" -type f -print0 2>/dev/null)

  if [[ "$found_large" -eq 0 ]]; then
    echo "    (none)"
  fi

  # --- If git repo, also warn about large files buried in HISTORY
  #     (not just the current working tree) ---
  if [[ -d "$dir/.git" ]]; then
    echo "  Large files in git HISTORY (may exist even if deleted now):"
    hist_found=0
    # List all blobs in all commits with size, sorted descending, filter by threshold
	while IFS=$'\t' read -r size path; do
      if (( size > THRESHOLD_BYTES )); then
        human=$(( size / 1024 / 1024 ))
        echo "    - $path (~${human}MB, in history)"
        hist_found=1
      fi
    done < <(
      git -C "$dir" rev-list --objects --all 2>/dev/null |
      git -C "$dir" cat-file --batch-check=$'%(objecttype)\t%(objectsize)\t%(rest)' 2>/dev/null |
      awk -F'\t' '$1=="blob" {print $2"\t"$3}'
    )
    if [[ "$hist_found" -eq 0 ]]; then
      echo "    (none found)"
    else
      echo "    NOTE: these will be pulled in by 'git subtree add' even though"
      echo "          it's full history. Use a cleaned scratch clone (option b)"
      echo "          or filter-repo if you want them gone for good."
    fi
  fi

  echo
done

echo "=================================================================="
echo "Scan complete."
echo "Legend:"
echo "  Git: YES -> tracked; consider git subtree add (see per-project plan)"
echo "  Git: NO  -> untracked; just copy current files, skip big ones"
echo "=================================================================="
