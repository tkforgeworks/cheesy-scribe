# cheesy-scribe

An app based on the tasting note book from [33Books](https://www.33books.com), specifically for cheese tastings. Track, record, and look back at your favorite cheeses of all time.

## Status

Greenfield — design and architecture are still being investigated. No application code yet.

## Contributing / branch policy

This repo follows the TK ForgeWorks branching model ([`docs/branching-and-release.md`](https://github.com/tkforgeworks/.github/blob/main/docs/branching-and-release.md)):

- `main` is the released state and only moves by merging a release PR.
- Work accumulates on the current release branch, `v0.1.0/main`.
- Topic branches are named `v0.1.0/CHEESE-N-short-topic` and PR into the release branch, never into `main`.
- Commit subjects are the changelog: `CHEESE-N: Imperative summary`, with `CHEESE-N: Fix ...` for bug fixes.

Both branches are protected by repository rulesets per [`docs/branch-protection-ruleset.md`](https://github.com/tkforgeworks/.github/blob/main/docs/branch-protection-ruleset.md): `main` is PR-only with no force-push, no deletion, and no bypass; `v*/main` blocks force-push and deletion. A required CI status check will be added to the `main` ruleset once CI exists and has reported on a PR.

Work is tracked in Jira project [CHEESE](https://tkforgeworks.atlassian.net/browse/CHEESE).

## License

Apache-2.0 — see [`LICENSE`](LICENSE). Image assets (logos, icons,
illustrations, screenshots) are **not** covered and are all rights reserved;
see [`NOTICE`](NOTICE).
