# releaser-action

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
