# Code Review Subagents

Review in this repository is split into subagents by ownership boundary, the same boundaries `.agents/rules.md` and
`.agents/architecture.md` draw. One reviewer holding the whole rule set drifts toward the rules it read last; a reviewer
holding one section reads all of it. Definitions live in `.claude/agents/review-*.md`. The built-in `/code-review`
hunts generic bugs and stays in use; these agents hold the rules that are specific to this repository.

## Division Of Labor

Mechanical checks are run, not reread. Formatting, lint, comment density, coverage floors, commit subjects and the
repo lint tests under `test/lint/` already have gates; `review-gate` runs them and reports raw output, and no other
reviewer spends attention on what a gate would catch. Reviewers own the judgment half: whether a change respects an
ownership rule, whether a comment carries anything, whether a test asserts the behavior or the implementation.

| Agent                   | Owns                                                                                  | Reads first                                           |
| ----------------------- | ------------------------------------------------------------------------------------- | ----------------------------------------------------- |
| `review-gate`           | Runs format, analyze, comment density, focused tests, Go/plugin checks; no judgment   | `.agents/commands.md` Verify, Testing                 |
| `review-flutter`        | Dart/Flutter style beyond lint, Riverpod state, UI conventions, localization, layering | `.agents/rules.md` Style; `architecture.md` State Management, Settings Rows |
| `review-core-lifecycle` | Core API safety, lifecycle ownership, Go/JNI/Kotlin/Rust, IPC envelope, Clash.Meta budget | `.agents/rules.md` Core API Safety, Lifecycle; `architecture.md` Core, Lifecycle |
| `review-tests`          | Test presence, seams, coverage floors, host-agnostic assertions, flaky patterns        | `.agents/rules.md` Testing Rules                      |
| `review-hygiene`        | Comment value, knowledge placement, generated files, commit message and trailers, dependency ceilings | `.agents/rules.md` Comments, Commit Messages, Generated Code; `project.md` Dependency Ceilings |
| `review-verify`         | Adversarially confirms or refutes one finding; never produces new ones                | The finding and the code it names                     |

## Routing

The orchestrator maps changed paths to reviewers and spawns only the matching ones. `review-gate` and `review-hygiene`
run on every review. A path matching two rows gets both reviewers.

| Changed path                                                                                                        | Reviewer                |
| ------------------------------------------------------------------------------------------------------------------- | ----------------------- |
| `lib/core/**`, `lib/manager/**`, `lib/providers/actions/**`, `lib/plugins/**`, `lib/common/{boot_guard,tray,system,launch}.dart` | `review-core-lifecycle` |
| `core/**`, `android/**`, `services/helper/**`, `plugins/{rust_api,tray,wifi_ssid,proxy}/**`, `libclash/**`           | `review-core-lifecycle` |
| `core/Clash.Meta/**`                                                                                                 | `review-core-lifecycle` with the patch-budget question first |
| `lib/**` except the rows above, `arb/**`, `plugins/*/lib/**`                                                          | `review-flutter`        |
| `test/**`, `plugins/*/test/**`, `core/*_test.go`, `android/tests/**`, `tool/check_coverage.dart`                     | `review-tests`          |
| Any non-test code change with no test change in the same diff                                                       | `review-tests` (asks where the assertion lives) |
| `.agents/**`, `AGENTS.md`, `tool/**`, `.pre-commit-config.yaml`, `.github/**`, `pubspec.yaml`, `lint_options.yaml`  | `review-hygiene` (already always on) |

Generated output (`lib/l10n/intl/**`, `lib/**/generated/**`, `*.g.dart`, `*.freezed.dart`, `frb_generated*`) is never
reviewed line by line. A diff that touches it without a matching source change is one hygiene finding.

## Finding Format

Every reviewer returns findings in this shape, and nothing else at the top level:

```text
- file: lib/core/desktop/lifecycle.dart:142
  severity: blocker | should-fix | nit
  category: lifecycle | core-api | state | ui | l10n | test | comment | commit | generated | deps | style
  rule: .agents/rules.md#lifecycle-rules   (or "judgment" when no written rule applies)
  summary: one sentence stating the defect
  failure: concrete input or state -> wrong outcome   (required for blocker and should-fix)
  confidence: high | medium
```

- `blocker`: ships a bug, breaks an ownership rule, or fails a gate. `should-fix`: wrong but survivable, or a rule
  violation without a user-visible consequence. `nit`: taste; report at most five per review.
- A blocker or should-fix without a `failure` line is downgraded to a nit by the orchestrator. Naming a rule is not a
  failure scenario; the scenario is what the rule protects against, made concrete for this diff.
- Cite the rule section so the author can read the reason, and so a finding that cites nothing is visibly judgment.
- A reviewer that finds nothing says so in one line. Silence is read as "not run".

## Verification

Each blocker and should-fix goes to `review-verify` before it reaches the author. The verifier reads the code path the
finding names, tries to construct the failure, and answers `CONFIRMED`, `PLAUSIBLE` (the mechanism is real but the
reviewer could not reach the trigger), or `REFUTED` with the reason. Refuted findings are dropped; the rest are
reported with their verdict. Nits skip verification.

This step exists because reviewer false positives cost more than they look: an author who has been sent to check a
non-issue twice stops reading the third finding. Verification costs one focused agent per finding and is worth it.

## Running A Review

1. Export the diff once to the scratchpad (`git diff`, `git diff <base>...HEAD`, or `git show <sha>`), and list its
   files. Every reviewer reads that file; nobody runs a fresh diff.
2. Apply the routing table. Spawn the selected reviewers in parallel, each with the diff path, the files that routed
   to it and the reason, and the commit range when there is one.
3. Drop duplicate `file:line` entries keeping the higher severity, downgrade any blocker or should-fix that has no
   failure scenario, and cap nits at five.
4. Send each remaining blocker and should-fix to `review-verify`, one finding per agent, in parallel. Drop `REFUTED`.
5. Report gate results first, then findings ranked by severity with their verdict, then what was not covered: files
   no reviewer took, entry paths a reviewer could not trace, tests that did not run.
6. Do not fix in the same turn. Fixes are a separate request and follow the normal change workflow.

Reviewers read whatever context the diff needs and use `codegraph explore "<symbol>"` to follow call paths, but do
not review files outside the diff unless a finding leads there, and they say so when it does. A diff above roughly
forty files is split by top-level directory. The written rules are restated inside each agent definition rather
than linked, so a reviewer holds them without a fetch that can be dropped from context; when `.agents/rules.md`
changes, the matching agent definition changes in the same commit.

## Model And Color

The terminal color of each agent says which model it runs on, so a reviewer's cost and depth are visible at a glance.

| Color  | Model     | Agents                                  | Why                                                     |
| ------ | --------- | --------------------------------------- | ------------------------------------------------------- |
| red    | `inherit` | `review-core-lifecycle`, `review-verify` | Concurrency and ownership reasoning; refuting a finding needs the strongest model in the session |
| blue   | `sonnet`  | `review-flutter`, `review-tests`, `review-hygiene` | Rule matching over a bounded diff                       |
| green  | `haiku`   | `review-gate`                           | Runs commands and quotes output; no judgment            |

## Gates And Their Real Force

`review-gate` reports what it ran, and the report names the gap when a check could not run:

| Check                                             | Force                                                            |
| ------------------------------------------------- | ---------------------------------------------------------------- |
| `dart format --output=none --set-exit-if-changed` | pre-commit hook and CI                                           |
| `flutter analyze --no-fatal-infos`                | pre-push hook and CI; root only, `plugins/**` excluded           |
| `bash tool/check_comment_density.sh <files>`      | pre-commit hook, `PostToolUse` hook in Claude Code and Codex     |
| `flutter test <focused paths>`                    | CI runs the full suite; locally the gate runs the routed subset  |
| `bash tool/check_plugins.sh`                      | CI; run when `plugins/**` changed                                |
| `CGO_ENABLED=0 go vet . && go test .` in `core/`  | CI; the `android && cgo` files need the NDK step and are not covered locally |
| `tool/check_commit_msg.sh`                        | commit-msg hook; only on the commits under review                |
| `test/lint/*_test.dart`                           | part of `flutter test`; run explicitly when `lib/` changed       |
