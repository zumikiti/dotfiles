# Let Renovate propose fisher plugin updates

Renovate, configured in `renovate.json`, proposes digest bumps for the entries in `fish/fish_plugins`. Because that file has no version field, Renovate compares each pinned SHA against the upstream default-branch HEAD rather than release tags. A human reads the upstream diff and merges the pull request; automerge stays off, since a digest bump can pull in unreleased commits.

Merging only changes the symlinked plugin list, so `fisher update` must still be run locally to apply the new pinned SHA. This supersedes the clause of [ADR 0002](0002-pin-fisher-plugins.md) that updates change only through an explicit user-initiated edit, while keeping its policy of pinning every entry to a full commit SHA.

Flox and `lazy.nvim` have no Renovate datasource or manager here, so they remain manual and the Manual Update Policy of [ADR 0001](0001-flox-first-wave-for-cli-tools.md) still applies to them.
