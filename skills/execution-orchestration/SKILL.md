---
name: execution-orchestration
description: >-
  Plan before execution and require explicit user approval to start any
  state-changing work. Use when the user asks to execute, implement, fix,
  deploy, migrate, or modify anything multi-step. Do not use for read-only
  queries.
license: MIT
compatibility: linux, macos, windows
metadata:
  author: hakuni
  version: 1.0.0
  tags: [orchestration, planning, approval-gate, execution, general-workflow]
---

# Execution Orchestration & Approval Gate

## Overview
A universal protocol for orchestrating multi-step execution across any domain
(software engineering, configuration changes, content pipelines, data
migrations, automated operations). It mandates structured pre-execution
planning and explicit operator authorization before any state-changing action
is initiated.

## When to Use
- Any directive requesting execution of a multi-step workflow, task, script,
  build, deployment, or production run.
- Refactoring, modifying codebases, or altering configuration
  (skills, settings, tools, integrations).
- Data migrations, destructive changes, batch API calls, or infrastructure
  updates.
- Any non-trivial action where unexpected side effects could occur.

## When NOT to Use
- Pure read-only queries, questions, lookups, or file inspections
  (e.g. "read file X", "what does function Y do", "check status Z").
- Trivial, single-step idempotent checks explicitly requested by the user
  with no multi-step implications.

## Core Rules

### 1. Intercept & Hold (fail closed)
When the user gives an execution prompt (e.g. "execute this", "start the
process", "implement feature X", "fix bug Y", "update the configuration"):
- Do NOT invoke state-changing tools (file writes, database updates, API
  POSTs, remote pushes, deletions) immediately.
- Acknowledge the goal, then transition into the Planning & Gate phase.

### 2. Action Plan
Choose the plan class based on the weight of the work — the rule stays the
same: no execution before approval.

**Light plan** (for 2–4 step tasks with no destructive actions):
3–5 lines only — objective, steps, completion criteria.

**Full plan** (for multi-file, destructive, or external-runtime/service work),
containing:
- **Objective & Scope:** what is being built/fixed, why, and explicit
  boundaries (in-scope vs out-of-scope).
- **Step-by-Step Breakdown:**
  * Choose an execution strategy based on runtime capabilities (best first):
    1. **External orchestrator available** (separate workers, isolated
       workspaces, task DAG): split large/parallel or multi-repo work into a
       task DAG — one unit of work per worker, each with an isolated
       workspace/copy so nothing overwrites anything else.
    2. **Internal subagents only:** split independent work across subagents;
       work touching the same files stays sequential.
    3. **Neither:** sequential execution with a verifiable checkpoint after
       each step before proceeding.
  * If the runtime has a separate orchestration mechanism, state explicitly
    in the plan why it is (or is not) being used.
  * Mark destructive steps with **⚠️ hard-gate** (see Rule 4).
  * For ordinary sequential work: Inspect → Change → Verify → Handoff.
- **Inputs & File Targets:** exact file paths, commands, tools, or
  dependencies involved.
- **Expected Artifacts:** tangible outputs at each step (modified files, test
  results, manifests, logs).
- **Verification & Acceptance Criteria:** deterministic tests, QC metrics,
  status codes, or visual evidence required to declare success.
- **Risk & Boundaries:** external API calls, credentials, cost/quota impact,
  breaking changes.

### 3. Approval Gate Presentation
Present the plan clearly in plain language:
- Outline the steps and deliverables cleanly using bullet points.
- State what will happen upon approval.
- End with a direct call for operator approval, e.g.:
  "Type **'execute'** or confirm to start."

Approval may be **partial**: "execute steps 1–3", "execute all except step 4".
Steps outside the approved scope are considered NOT approved
(fail-closed still applies).

### 4. Autonomous Execution Post-Approval
Once explicit approval is received ("execute", "go ahead", "yes", "approved"):

- **Persist the plan:** write the approved plan to a file in the working
  directory (e.g. `.plan.md`) before the first step. Mark each completed step
  in that file. If the session is interrupted or compacted, resume from the
  last recorded step — do not restart from the beginning.
- Execute step by step WITHOUT stopping to ask permission for routine
  technical sub-decisions.
- At each step, produce **real evidence** (command output, test results,
  diffs) — not claims ("it should work").
- **Hard-gate:** steps marked ⚠️ (large rm -rf, drop table, force push,
  production deploy, data deletion) ALWAYS require a second confirmation at
  the moment of execution, even after general approval.
- **Scope-creep guard:** newly discovered work outside the plan is recorded
  as *discovered work* — act on it only if it is a prerequisite of the
  current step; otherwise collect it for the closing report. If blocking →
  halt.
- When executing parallel/dependent tasks: place approval points ONLY at
  critical decisions; routine progress is reported concisely without asking
  permission; dependent steps start only after their prerequisites are
  verified.
- **Halt condition:** if a blocker, unexpected failure, or out-of-scope risk
  arises — STOP immediately, diagnose the root cause, and present options to
  the operator.

### 5. Closing Report (mandatory)
After the final step, produce a closing report:
- Each acceptance criterion mapped to its evidence (✅/❌).
- List of pending *discovered work* (if any).
- Remaining risks and recommended follow-ups (if any).
