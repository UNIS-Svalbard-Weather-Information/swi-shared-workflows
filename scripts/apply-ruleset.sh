#!/usr/bin/env bash
# Apply templates/rulesets/default-branch.json to public repositories that have no
# ruleset yet. Dry run unless --apply is given. Needs `gh` with a token that has
# Administration: write on the target repositories (use a short-lived one).
#
#   scripts/apply-ruleset.sh                 # list what would change
#   scripts/apply-ruleset.sh --apply repo1 repo2
set -euo pipefail

ORG="${ORG:-UNIS-Svalbard-Weather-Information}"
HERE="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE="$HERE/../templates/rulesets/default-branch.json"
NAME="$(python3 -c "import json,sys;print(json.load(open(sys.argv[1]))['name'])" "$TEMPLATE")"

apply=false
if [ "${1:-}" = "--apply" ]; then apply=true; shift; fi

if [ "$#" -gt 0 ]; then
  repos=("$@")
else
  mapfile -t repos < <(gh repo list "$ORG" --limit 200 --no-archived --visibility public --json name --jq '.[].name')
fi

for repo in "${repos[@]}"; do
  existing="$(gh api "repos/$ORG/$repo/rulesets" --jq 'length' 2>/dev/null || echo "?")"
  if [ "$existing" != "0" ]; then
    echo "skip   $repo (rulesets: $existing)"
    continue
  fi
  if $apply; then
    gh api --method POST "repos/$ORG/$repo/rulesets" --input "$TEMPLATE" --jq '"applied " + .name' | sed "s/\$/ -> $repo/"
  else
    echo "would apply '$NAME' to $repo"
  fi
done
