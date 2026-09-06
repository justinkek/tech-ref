<h1 align="center">tech-ref</h1>

<p align="center">How a piece of work is built, written down before it is.</p>

## 1. What it is

`rules/tech-steps.md` states one format for implementation steps: a file tree of everything the work touches, a sequence flow of the calls it changes, then nested toggles carrying each change and the code that makes it. It goes to `.tech-steps/<name>.md`, one file per piece of work.

`hooks/guard-tech-steps.sh` holds a write to that format. It reads the text a session is about to write - a file edit or a page update - and denies the write when a tree, a flow or a summary breaks a rule the file states, naming each line it refused.

## 2. How it works

| File                          | When it runs                | What it does                                                    |
| ----------------------------- | --------------------------- | --------------------------------------------------------------- |
| `hooks/load-agents-md.sh`     | session start               | prints `AGENTS.md` into the session, with an absolute rules path |
| `hooks/guard-tech-steps.sh`   | before an edit or a write   | denies a write whose steps break the format                     |

The guard checks what a machine can check: the 120 character tree headings, the markers and joins of every file line, the column every sentence starts at, a path named twice in one tree, the `title` and `autonumber` of a sequence flow, its two shading colours, and the verb each summary opens on. Everything else stays a rule in the file.

## 3. Install

Copy/paste into your CLI prompt:

```text
Install the tech-ref plugin from https://github.com/justinkek/tech-ref, refer to the repo's INSTALL.md for instructions.
```

Or 🔗 [check the installation instructions](INSTALL.md).

## 4. Tests

    tests/run-tests
