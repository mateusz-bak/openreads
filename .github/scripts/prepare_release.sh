#!/bin/bash
# Prepares a release from the draft:
# bumps pubspec.yaml and writes the changelog from the draft.
# Saves TAG, VERSION and BUILD to $GITHUB_ENV for the next steps.
set -eo pipefail
export LC_ALL=C.UTF-8

limit=500

drafts="$(gh api "repos/$GITHUB_REPOSITORY/releases" --jq '[.[] | select(.draft)]')"
if [ "$(jq length <<< "$drafts")" -ne 1 ]; then
  echo "::error::Must be exactly one draft release"
  exit 1
fi
draft="$(jq -c '.[0]' <<< "$drafts")"
tag="$(jq -r .tag_name <<< "$draft")"
version="${tag#v}"
if [[ "$tag" != v* ]]; then
  echo "::error::Draft release tag $tag must start with v"
  exit 1
fi
# an existing tag (e.g. from a manual publish) would keep the release on its old commit
if [ -n "$(git ls-remote --tags origin "refs/tags/$tag")" ]; then
  echo "::error::Tag $tag already exists, delete it first"
  exit 1
fi

# version
current="$(grep '^version:' pubspec.yaml | awk '{print $2}')"
current_version="${current%+*}"
build=$((${current#*+} + 1))
highest="$(printf '%s\n%s\n' "$current_version" "$version" | sort -V | tail -n 1)"
if [ "$version" = "$current_version" ] || [ "$highest" != "$version" ]; then
  echo "::error::Draft version $version must be higher than $current_version"
  exit 1
fi
sed -i "s/^version: .*/version: $version+$build/" pubspec.yaml

# changelog, without blank lines
body="$(jq -r .body <<< "$draft")"
if [[ "$body" != *'<!-- changelog -->'* || "$body" != *'<!-- /changelog -->'* ]]; then
  echo "::error::The draft release needs both <!-- changelog --> and <!-- /changelog -->"
  exit 1
fi
changelog="$(tr -d '\r' <<< "$body" \
  | sed -n '/<!-- changelog -->/,/<!-- \/changelog -->/p' \
  | grep -v -e '<!-- changelog -->' -e '<!-- /changelog -->' -e '^[[:space:]]*$' || true)"
if [ -z "$changelog" ]; then
  echo "::error::No text between <!-- changelog --> and <!-- /changelog --> in the draft release"
  exit 1
fi

# Drop lines from the end of changelog until it fits defined limit
while [ "${#changelog}" -gt "$limit" ] && [[ "$changelog" == *$'\n'* ]]; do
  changelog="${changelog%$'\n'*}"
done
# a single line that is still too long is cut at the last space
if [ "${#changelog}" -gt "$limit" ]; then
  changelog="${changelog:0:$limit}"
  changelog="${changelog% *}"
fi
printf '%s' "$changelog" > "fastlane/metadata/android/en-US/changelogs/$build.txt"

echo "Version $current -> $version+$build, changelog ${#changelog} characters:"
echo "$changelog"
{
  echo "TAG=$tag"
  echo "VERSION=$version"
  echo "BUILD=$build"
} >> "$GITHUB_ENV"
