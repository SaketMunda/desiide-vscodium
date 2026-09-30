# Desiide patches

Everything that turns VSCodium into Desiide lives in this folder. VSCodium's `prepare_vscode.sh`
sources `apply.sh` (the only change to VSCodium's own scripts) after its own patches, with the
working directory set to the upstream `vscode/` checkout.

| File | What it does |
|---|---|
| `apply.sh` | Hook body: merges `product.json`, copies `resources/`, applies `*.patch` in order |
| `product.json` | Branding overlay merged over VSCodium's product.json: name, `applicationName` `desiide`, data folders `.desiide`/`.desiide-server`, `urlProtocol` `desiide`, bundle IDs, fresh Windows GUIDs, issue/docs links |
| `resources/` | App icons (macOS `.icns`, Linux, server/web). Generated; don't edit by hand |
| `src/` | File overlay on upstream `src/`: the editor watermark (letterpress) SVGs and the workbench product icon (`code-icon.svg`). Generated |
| `icons/desiide-icon.svg` | Icon source (placeholder until open decision #3). `icons/generate.sh` regenerates `resources/` (macOS) |
| `01-default-theme.patch` | Default color theme: Desiide Dark / Desiide Light |

Branding that VSCodium already parameterizes (`APP_NAME`, `BINARY_NAME`, `ORG_NAME`, ...) is set by
`scripts/build-editor.sh` in the Desiide repo, which is the supported way to build.

## Rules
- AI/Jev features never go here: they belong in the `desiide-ai` extension (ADR-002). Patches are
  limited to branding, gallery, default layout, and bundling.
- One concern per patch, named `NN-short-name.patch`, starting with a header: purpose, why the
  extension API can't do it, upstream files touched. `git apply` ignores the header text.
- Generate patches with `git diff` inside `vscode/`. Never hand-edit the `vscode/` tree and leave it.
- Prefer overlays (`product.json`, `resources/`) over diffs: they survive upstream changes.

## Upstream sync
Merge the new VSCodium tag, re-run `scripts/build-editor.sh --clean`, and regenerate any patch that
no longer applies (`git apply --check` in a fresh `vscode/` tells you quickly).
