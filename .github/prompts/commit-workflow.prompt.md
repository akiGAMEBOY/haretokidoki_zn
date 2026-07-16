---
mode: agent
description: A concise, reusable commit helper for development changes, publication toggles, and article batch commits.
---

# Commit workflow helper

Use this command when you need a short, low-risk workflow for creating a commit in different situations.

> 出力は日本語で表示してください。

## Inputs
- workflow: ${input:workflow} (development | publish-toggle | article-batch)
- targetPath: ${input:targetPath} (optional)
- targetFiles: ${input:targetFiles} (optional, comma-separated)
- referenceMessageTemplate: ${input:referenceMessageTemplate} (optional)
- commitPrefix: ${input:commitPrefix} (optional, default: "chore")
- targetState: ${input:targetState} (optional, draft or publish)
- dryRun: ${input:dryRun} (optional, true/false)

## Core principles
- Prefer the shortest path that is safe and understandable.
- Avoid unrelated changes.
- Ask for confirmation when the intent is unclear or the scope is large.
- If no meaningful change is detected, do not create a commit.

## Behavior by workflow

### development
- Use this for ordinary source changes.
- Review the current diff or selected files.
- Suggest a concise commit message such as:
  - `${commitPrefix}: update <area>`
  - `${commitPrefix}: fix <issue>`

### publish-toggle
- Use this for changing publication state.
- Keep the change limited to the publication flag, typically `published`.
- Preserve all other content exactly.
- Suggest a message such as:
  - `${commitPrefix}: publish article`
  - `${commitPrefix}: draft article`

### article-batch
- Use this for a grouped commit across multiple article files.
- Keep the batch focused and explain the intent clearly.
- Suggest a message such as:
  - `${commitPrefix}: batch update articles`
  - `${commitPrefix}: update article set`

## Message style
- Prefer a concise conventional style.
- Use the reference message template as a base, but adapt it to the selected workflow.
- Keep messages short enough to be reused across projects.

## Examples
- workflow: development, referenceMessageTemplate: "chore: update implementation" -> "chore: update implementation"
- workflow: publish-toggle, targetState: publish -> "chore: publish article"
- workflow: article-batch, targetFiles: articles/foo.md, articles/bar.md -> "chore: batch update articles"
