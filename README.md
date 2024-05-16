# releaser-action

> Findy Agency is an open-source project for a decentralized identity agency.
> OP Lab developed it from 2019 to 2024. The project is no longer maintained,
> but the work will continue with new goals and a new mission.
> Follow [the blog](https://findy-network.github.io/blog/) for updates.

GitHub action for tagging a release: Releaser creates tag if changes are found since the latest release to main branch.

## Inputs

## `token`

**Required** Personal access token with repo permission. PAT is needed so that GitHub events are generated for tag push.

## `gate`

Name of the dev workflow acting as gate - workflow needs to pass for release to happen. Separate multiple workflows with comma.

## Example usage

```yml
uses: findy-network/releaser-action@v5
with:
  token: ${{ secrets.RELEASER_PAT }}
  gate: test
```
