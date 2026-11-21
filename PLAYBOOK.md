# Idle Stories — playbook

This file turns a request into a known routine. It follows the same pipeline the owner uses on the auto-trade project, cut down to what a Flutter game needs. Read `AGENTS.md` first, then find the pattern here.

## The pipeline

1. **Issue.** Every piece of work beyond a one-line fix has a GitHub issue in `aashishtamsya/idle-stories`. Issues are the work queue and the single source of truth. Give each one a `priority:*` and a `component:*` label, and claim it with `status:in-progress` while working on it.
2. **Plan.** Post a short plan as a comment on the issue: the pattern, the files, the checks and the risks. Anything only the owner can decide becomes a `question` issue (add `blocked` if work cannot continue without it).
3. **Branch.** Work on a branch named `aashishtamsya/<issue>-<slug>` from `main`.
4. **Implement.** Make the smallest change that closes the issue.
5. **Verify.** Run the checks for the pattern and look at the result on the simulator.
6. **Gate.** `flutter analyze` and `flutter test --reporter expanded` must both pass before a commit.
7. **Commit, push, draft PR.** Open the PR as a draft with `Closes #<n>`.
8. **Review.** Run `/code-review` on the diff and fix or answer every finding.
9. **Merge.** The owner approves each merge.
10. **Report.** Say what changed, what was observed, what was not seen and what is still open.

## Patterns

| # | Pattern | Signals | Checks |
| --- | --- | --- | --- |
| G1 | Art or look of a screen | "looks", "asset", "style", "office", "icon", a screenshot | The owner's art process in `AGENTS.md` (research, gap analysis, HTML variations, wait, guideline, build), then a simulator screenshot |
| G2 | Interface behaviour | "button", "screen", "layout", "settings" | Tests, then a simulator screenshot of each changed state |
| G3 | Economy or game rules | "cost", "income", "manager", "offline", "prestige" | A unit test for each rule in `test/` |
| G4 | Story, region or language | "story", "comic", "translate", a country or language name | All text through `lib/strings.dart`; the region test; a native-speaker review issue for each new language |
| G5 | Monetisation | "ad", "shop", "bundle", "price", "pass" | The golden rule in `AGENTS.md`; no forced ad and no interrupting offer |
| G6 | Bug | "broken", "wrong", "resets", an error | Reproduce it first, add a test that fails, then fix |
| G7 | Research | "compare", "competitors", "what do other games do" | Store screenshots and sources; findings go into issues, not only into chat |
| G8 | Docs or process | "agents file", "playbook", "record" | Update the matching file in the same commit |

## Labels

- Priority: `priority:p0` (blocks release), `priority:p1` (needed for release), `priority:p2` (after release).
- Component: `component:art`, `component:ui`, `component:economy`, `component:story`, `component:l10n`, `component:monetisation`, `component:audio`, `component:process`.
- State: `status:in-progress`, `blocked`, `question`.

## Learning loop

When something surprises you, write it down where the next agent will find it: a fact about this repository goes into `AGENTS.md`, and a correction about how the agent should behave goes into `~/.claude/FEEDBACK.md`.
