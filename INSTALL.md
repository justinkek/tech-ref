# Installing tech-ref

One rules file, and the guard that holds a write to what it says. Every harness
runs the same guard; only the registration differs.

## 1. Claude Code, ZCode

    claude plugin marketplace add justinkek/tech-ref
    claude plugin install tech-ref@tech-ref

In ZCode, add `justinkek/tech-ref` through Settings, Marketplace. It preloads the Claude Code marketplace format and reads the same two manifests.

## 2. Codex

    codex plugin marketplace add justinkek/tech-ref
    codex plugin add tech-ref@tech-ref

Codex does not run a plugin's own `hooks.json` yet
([openai/codex#16430](https://github.com/openai/codex/issues/16430)): the plugin installs and reports itself enabled, and a session fires none of its hooks. Until that changes, register the same command by hand in `~/.codex/config.toml`, which is the layer Codex does read:

    [[hooks.PreToolUse]]
    matcher = "Edit|Write"
    [[hooks.PreToolUse.hooks]]
    type = "command"
    command = "<path to this checkout>/hooks/guard-tech-steps.sh"

Codex asks you to trust each command the first time it meets it, and they stay trusted until the command text changes. Codex reads `~/.codex/AGENTS.md` itself, so put the pointer line from this repository's `AGENTS.md` there. Keep the plugin installed alongside: when plugin hooks land, delete this block.

## 3. Pi

    pi install git:github.com/justinkek/tech-ref

Pi cannot register a subprocess, so `harness-adapters/pi/src/index.ts` is a shim: it builds the line of JSON the guard already reads on stdin, spawns `hooks/guard-tech-steps.sh`, and turns a refusal into a denied write. It carries no rule of its own, and it needs a shell on the machine, which the other three already require.
