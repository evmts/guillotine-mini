# 1) PRD — Smithers v1 (Native macOS agent terminal + chat)

## 1.1 Summary

Smithers is a native macOS application that runs Claude-powered coding agents locally (via the Claude Agent SDK in Python) and presents them in a high-signal chat UI that transparently shows tool usage, supports streaming, and persists sessions. It will evolve into a “workbench” like Conductor (workspaces, diffs, checkpoints, scripts, todos) while retaining the terminal-native ergonomics that made Ghostty a good starting point.

Ghostty’s architecture (Swift UI on macOS + Zig core via `libghostty`) is a strong base for an app that combines a terminal surface and modern UI.([Ghostty][1])

---

## 1.2 Problem & Opportunity

### Problem

Developers using CLI coding agents today face a tradeoff:

- **Terminal-first tools** are fast and scriptable but are not great at **long-running session readability**, **tool transparency**, **diff/review**, and **multi-thread/session management**.
- **Web chat UIs** are readable but don’t feel local, don’t integrate cleanly with terminal workflows, and don’t scale well to real codebase iteration patterns (test loops, diffs, checkpoints, multiple parallel attempts).

### Opportunity

Create a native macOS agent workbench that:

- renders agent sessions like a first-class chat app
- keeps “what happened” and “why” legible (tool calls, outputs, diffs, checkpoints)
- supports the “parallel attempts” workflow Conductor formalizes as workspaces([Conductor][2])
- adopts extensibility primitives like pi-mono (sessions as trees, steering messages, prompt templates, dynamic context)([Shitty Coding Agent][3])
- supports “agent guidance files” and team workflows like Amp (AGENTS.md, thread sharing, streaming JSON schemas, permissions, subagents, oracle/second-opinion)([AmpCode][4])

---

## 1.3 Target Users / Personas

1. **Solo engineer (primary)**
   Wants rapid codebase iteration: “read files → edit → run tests → review diff → repeat,” with strong undo/revert and searchable history.

2. **Power user / agent harness operator**
   Runs multiple parallel agent attempts, wants deterministic run scripts, reproducibility, and structured outputs.

3. **Team lead (later phase)**
   Wants shareable runs, PR-ready summaries, auditability, and standardization via guidance files and tool policies.

---

## 1.4 Product Principles

1. **Legibility over cleverness**: tool calls/results are visible, structured, and navigable; long outputs never overwhelm the chat.
2. **Native feel**: macOS conventions, keyboard-first, accessibility by default.
3. **Safety with velocity**: permissions and guardrails that don’t destroy flow (pattern-based approvals; sensible defaults).
4. **Extensible primitives**: slash commands, prompt templates, MCP tools, workspace scripts, and agent profiles.
5. **Session durability**: auto-save, crash-safe, resumable.

---

## 1.5 Competitive Feature Targets (what we borrow)

### From Conductor (workspace-centric coding workflow)

- **Parallel workspaces / isolated environments** for concurrent attempts.([Conductor][2])
- **Diff viewer** to review changes and guide towards merge actions.([Conductor][5])
- **Scripts** (setup/run/archive) with env vars; “Run” button.([Conductor][6])
- **Testing** patterns including run scripts and (optional) spotlight-style syncing.([Conductor][7])
- **Todos** integrated with chat via `@todos` and “blocked until done.”([Conductor][8])
- **Checkpoints** that revert both code and conversation after a specific turn.([Conductor][9])
- **Slash commands** stored as Markdown files in `.claude/commands`.([Conductor][10])
- **MCP** support to add external tools/data sources.([Conductor][11])

### From pi-mono (minimal core + powerful primitives)

- **Tree-structured sessions** and “continue from any point.”([Shitty Coding Agent][3])
- **Steering messages while agent runs** (steer vs follow-up).([Shitty Coding Agent][3])
- **Prompt templates** (`/name`) and dynamic context injection.([Shitty Coding Agent][3])
- **Compaction/summarization** near context limits, customizable.([Shitty Coding Agent][3])

### From Amp (production harness ergonomics)

- **AGENTS.md** guidance auto-loaded to shape behavior.([AmpCode][4])
- **Tool permissions defaults** for common dev commands; confirm destructive ones.([AmpCode][4])
- **Subagents** for parallelizable tasks + main-thread context hygiene.([AmpCode][4])
- **Thread sharing** concept (in Smithers: export/share artifacts).([AmpCode][4])
- **Streaming JSON schema** as an integration pattern (useful for our Swift↔Python bridge).([AmpCode][4])
- **MCP configuration and auth** patterns (Smithers will likely offer a UI for these).([AmpCode][4])

---

## 1.6 Scope

### MVP (v1): “Readable Claude Agent sessions”

**Goal:** a user can run a coding agent session, watch it stream, understand tool usage, and resume later.

**MVP Features**

1. **Sessions**

   - Create, rename, delete, duplicate
   - Sidebar grouping + search
   - Auto-save + resume

2. **Chat UI**

   - User + assistant messages
   - Markdown rendering (with code blocks)
   - Streaming (smooth append, jump-to-bottom controls)

3. **Tool transparency**

   - Tool call cards: name, inputs, status, outputs
   - Collapsible long outputs + “Open in viewer”
   - Per-tool “copy” and “open file” affordances where relevant

4. **Run control**

   - Stop/cancel current run
   - Retry last prompt
   - Error states surfaced with actionable recovery

5. **Basic workspace context**

   - “Open Folder…” and bind session to a working directory for tools like Read/Edit/Bash

6. **Bridge**

   - Python subprocess + NDJSON/JSON-RPC streaming protocol

### v1.5: “Coding harness ergonomics”

- Diff viewer + “changes since last prompt”
- Checkpoints + revert
- Todos panel + `@todos` injection
- Slash commands + prompt templates (`/`)
- Basic permissions (allow list + confirm list)
- MCP config reading + tool list display

### v2: “Parallel agent workbench”

- Multiple workspaces per repo, one per feature (like Conductor).([Conductor][12])
- Workspace scripts (setup/run/archive), ports, run panel.([Conductor][6])
- Subagents UI and orchestration; “oracle”/review mode.([AmpCode][4])
- Spotlight testing option (advanced; often not needed if run-from-worktree works).([Conductor][7])
- Sharing/export with stable links (team mode later).

---

## 1.7 Non-Functional Requirements

- **Performance:** smooth with 1000+ messages; avoid re-render storms; virtualized message list.
- **Reliability:** crash-safe auto-save; deterministic replay from an event log.
- **Security:** permission gating for Bash/Edit; path protection; clear user confirmation.
- **Accessibility:** VoiceOver, keyboard navigation, reduced motion compatibility.
- **Native UX:** system colors/typography; macOS idioms.

---

## 1.8 Success Metrics (for v1)

- Time-to-first-response < 5 seconds after prompt (assuming model latency).
- < 1% sessions lost due to crash (auto-save).
- Tool call comprehension: users can answer “what commands ran?” without guessing.
- ≥ 70% of sessions resumed at least once (proves persistence + usefulness).
- App remains responsive while streaming and while tool output is large.

---

## 1.9 Decisions for the 6 explicit questions

1. **Very long tool outputs**
   Default: **truncate in-chat**, store full output offscreen (disk-backed), provide “Open Output Viewer” with search, copy, save, and open-in-terminal/file actions. In chat show: summary + first N lines + byte/line count.

2. **Tool calls inline or separate panel?**
   Hybrid:

- **Inline collapsible tool cards** in the transcript (chronological truth).
- Optional **Inspector panel** to view the selected tool in full detail (full output, metadata, timestamps, raw JSON).

3. **Cost/token usage without clutter**
   Show as a compact **status pill** in the header (e.g., “~$0.03 • 18k tok”) that opens a popover for full breakdown. Keep per-message usage in the Inspector only.

4. **Best way to render streaming markdown**
   During streaming: render as **plain text with minimal styling** (monospace for code fences once detected). When the message finalizes: re-render to full markdown. Use the SDK’s partial streaming events to append text chunks.([Claude][13])

5. **Errors display & recovery**
   Inline error cards at the point of failure (tool or agent), with actions:

- Retry tool
- Retry last prompt
- Copy diagnostic
- “Open logs”
  Also a non-modal banner for connection/auth issues.

6. **Auto-save?**
   Yes: **always auto-save** (event-log style) + explicit **Export** (Markdown/HTML/JSON) and “Duplicate session” for branching.

---

# 2) Design Spec — SwiftUI UX/UI for Smithers chat + harness features

## 2.1 Information Architecture

### Primary layout

Use `NavigationSplitView`:

- **Sidebar (left, 240–300pt)**
  Sessions + Workspaces (if enabled) + search + “New Chat” / “New Workspace”
- **Detail (center)**
  Chat transcript + input
- **Inspector (right, optional, 320–380pt)**
  Tool details / Diff / Todos / Usage / Session settings
  (macOS pattern: `NavigationSplitView` with `.columnVisibility` and `.inspector` style)

Why: keeps the transcript clean while giving power users a place for “verbose” artifacts.

---

## 2.2 Component Hierarchy (SwiftUI structure)

Below is the view structure and ownership of state (✅ = owns state).

### Root

- `SmithersView` ✅

  - State: `AppStore` (sessions, workspaces, preferences, selection)
  - Injects: `AgentSupervisor`, `PersistenceStore`

### Sidebar

- `SessionSidebar`

  - Props: `sessions`, `selectedSessionId`, `searchQuery`, `workspaceSelection`
  - Subcomponents:

    - `SidebarHeader` (“New Chat”, workspace selector, search)
    - `SessionGroupList` (Today / Yesterday / Last Week / Older)

      - `SessionRow` (title, preview, timestamp, status dot)

    - `SidebarFooter` (Settings, Logs)

### Detail

- `SessionDetailView` ✅ (per selected session)

  - State: `ChatViewModel` (messages array, streaming states, input draft, run state)
  - Subcomponents:

    - `SessionHeaderBar`

      - title (editable)
      - run status pill (idle/running/error)
      - buttons: Diff, Todos, Checkpoints, Inspector toggle

    - `MessageListView`

      - `MessageRowView` (switch on message type)

        - `UserBubbleView`
        - `AssistantBubbleView`

          - `MarkdownMessageView`
          - `ThinkingDisclosureView` (optional)
          - `ToolTimelineView` (tool cards)

        - `SystemEventRowView` (checkpoints, compaction summaries, errors)

    - `ComposerBarView`

      - multi-line input
      - send / stop
      - attachments placeholder
      - “/” command palette
      - `@todos` / `@file` chips (future)

### Inspector (optional)

- `InspectorView`

  - Tabs:

    - Tool (selected tool call/result)
    - Changes (diff)
    - Todos
    - Usage
    - Session Settings (model/tools/permissions)

### Terminal Surface (existing + future)

- `TerminalPaneView`

  - Can be:

    - Bottom drawer (like “Run panel”)
    - Or a right-side split next to chat

  - In v1: optional. In v2: integrated as the canonical “Bash output surface”.

---

## 2.3 Message Rendering Specs

### 2.3.1 User message

- **Alignment:** right
- **Bubble:** accent-tinted background (system accent w/ low opacity), 12–14pt padding
- **Typography:** `.body` (supports markdown-lite: inline code, links)
- **Metadata:** timestamp in `.caption` under bubble; shown on hover by default.

### 2.3.2 Assistant message

- **Alignment:** left, full-width container; content constrained to max ~80% width
- **Header line (optional):** small “Claude” label + timestamp
- **Markdown body:**

  - Standard markdown: headings, lists, quotes
  - Code blocks: monospaced, horizontal scroll, copy button
  - Inline code: monospaced with subtle background

### 2.3.3 Streaming behavior (assistant)

- While streaming:

  - Render as a “live” text view with a caret indicator.
  - Do not constantly re-parse markdown (performance); parse only after finalization.([Claude][13])

- Scroll behavior:

  - Auto-scroll only when user is at bottom.
  - If user scrolls up, show “Jump to latest” floating button.

### 2.3.4 Tool use display (inline tool cards)

**Card anatomy (collapsible)**

- Header row:

  - Icon by tool type (Read/Write/Edit/Bash/Glob/Grep/WebFetch/MCP/Task)
  - Title: `Bash` / `Read` / etc.
  - Summary: “npm test” or “Read src/auth.py”
  - Status: spinner (running) / check (success) / warning (error)
  - Actions: expand/collapse, copy, open-in-inspector

**Body (expanded)**

- Inputs section:

  - Key-value list (path, command, pattern)
  - Show raw JSON toggle (advanced)

- Output section:

  - For small outputs: render inline monospaced
  - For large outputs: show preview + “Open Output Viewer”

- Error section:

  - Error message + stack (debug only) + retry options

**Tool list naming**
We should support the built-in names the Agent SDK expects (e.g., `Bash`, `Read`, `Write`, `Edit`, `Glob`, `Grep`, `WebFetch`, `Task`) and MCP tools matching `mcp__<server>__<tool>`.([Claude][14])

### 2.3.5 Thinking / reasoning blocks (optional)

- Collapsed by default (disclosure group)
- Muted text color, smaller font
- Should be toggled with a preference; don’t force it into every transcript.

---

## 2.4 Input / Composer Design

### Layout

- Fixed bar at bottom, `controlBackgroundColor`
- Multi-line input expands up to ~6 lines, then scrolls internally
- Left side: “+” attachment stub (disabled in v1)
- Right side:

  - **Send** button (enabled when draft not empty & not running)
  - **Stop** button replaces Send while agent running

- Keyboard:

  - `⌘↩` send
  - `⇧↩` newline
  - `/` opens command palette
  - `⌘K` focuses sidebar search
  - `⌘D` opens diff (when available, like Conductor)([Conductor][12])

### While running: steer vs follow-up (pi-style)

- If agent running:

  - Enter = **Steer** (queued, interrupts remaining tools after current tool completes)([Shitty Coding Agent][3])
  - Option+Enter = **Follow-up** (queued but only sent after completion)([Shitty Coding Agent][3])

- UI shows a small “Queued: 1 steer” chip above input.

(You can ship this later; design should anticipate it now.)

---

## 2.5 Sidebar Enhancements (sessions + workspaces)

### Sessions list row

- Title (editable via context menu)
- Preview (first line of last assistant or user message)
- Right-side:

  - relative time
  - status dot:

    - idle: gray
    - running: pulsing accent
    - error: red

### Session actions (context menu)

- Rename
- Duplicate (fork)
- Export (Markdown/HTML/JSON)
- Delete

### Search

- Search sessions by title + preview
- (v1.5) optionally search inside transcripts (FTS)

### Workspaces (v1.5+)

A workspace is a directory + optional git worktree/branch identity, similar to Conductor’s “workspace per feature.”([Conductor][12])
Sidebar sections:

- Workspaces (pinned)
- Sessions (within workspace)

---

## 2.6 Status Indicators

### Header status pill

States:

- Idle
- Running (spinner + “Running…”)
- Tool: “Bash (2/5)”
- Error: “Auth error” (click for details)

### Token/cost

- Small pill next to status (collapsible)
- Click opens popover with:

  - input/output tokens
  - estimated cost
  - tool calls count
  - model name

---

## 2.7 Visual Mockups (descriptions)

### Mockup A — Empty state (no session selected)

- Center: “New Chat” primary button + “Open Folder…” secondary
- Recent sessions list below

### Mockup B — Active session streaming

- Transcript shows:

  - User bubble right
  - Assistant message left with text streaming and a caret
  - Inline tool cards appearing as they happen

- Bottom: input disabled except for “Stop”; queued message chip appears if user types

### Mockup C — Tool output overflow

- Tool card shows:

  - “Read: src/big_file.ts (142 KB)”
  - Preview first ~60 lines
  - Buttons: “Open Output Viewer”, “Open File”, “Copy”

- Output Viewer modal:

  - Search field, line numbers, “Copy selection”, “Save to file”

### Mockup D — Changes / Diff

- Inspector tab “Changes”
- File list left, diff right
- “Stage” and “Copy patch” actions (v2)
- “Checkpoint timeline” above diff (turn-by-turn)

### Mockup E — Checkpoint revert

- Hover on a user message shows a “Revert to here” icon (like Conductor).
- Confirmation sheet:

  - “This will delete messages after this point and revert code changes since then.”([Conductor][9])
  - Buttons: Cancel / Revert

### Mockup F — Todos

- Inspector “Todos” tab
- Checklist of items
- Composer supports `@todos` insertion so agent sees them, matching Conductor’s pattern.([Conductor][8])

---

# 3) Engineering Spec — Architecture, data flow, and Swift↔Python bridge

## 3.1 High-level Architecture

### Why Ghostty fork is a good base

Ghostty’s macOS app is Swift-based and links to a Zig core (`libghostty`), enabling native UI + embedded terminal surfaces.([Ghostty][1])
We leverage this to build a “chat + terminal” workbench without becoming a web wrapper.

### Modules (recommended)

- `Features/SmithersUI` (SwiftUI screens)
- `SmithersDomain` (models: Session, Message, ToolInvocation, Workspace)
- `SmithersAgentRuntime` (process + JSON-RPC bridge + streaming)
- `SmithersPersistence` (SQLite/event store)
- `SmithersWorkspace` (git worktrees, scripts, checkpoints)
- `SmithersPlugins` (slash commands, templates, guidance files, MCP config)

---

## 3.2 Data Model (Swift)

Replace the current minimal `Session` with a richer schema.

### Core entities

- `Workspace`

  - `id`, `name`, `rootPath`
  - `gitRepoRootPath` (optional)
  - `worktreePath` (optional, v1.5+)
  - scripts: setup/run/archive (v2)
  - env vars (computed; Conductor-style)([Conductor][15])

- `Session`

  - `id`, `workspaceId?`
  - `title`, `createdAt`, `updatedAt`
  - `status`: idle/running/error
  - `lastMessagePreview`

- `Message`

  - `id`, `sessionId`
  - `role`: user/assistant/system
  - `timestamp`
  - `blocks: [Block]`
  - `streamState`: none/streaming/final
  - `branchParentMessageId?` (for tree sessions / forks)([Shitty Coding Agent][3])

- `Block` (sum type)

  - `.markdown(text: String, renderedCacheKey: String?)`
  - `.toolUse(ToolInvocation)`
  - `.toolResult(ToolResultRef)` (points to disk-backed output)
  - `.error(AgentError)`
  - `.checkpoint(CheckpointRef)`
  - `.compactionSummary(String)` (optional)

- `ToolInvocation`

  - `toolUseId: String`
  - `name: String`
  - `input: JSONValue`
  - `status: pending/running/success/error`
  - timestamps

- `ToolResultRef`

  - `toolUseId`
  - `storageKey` (file path in App Support)
  - `preview` (first N lines)
  - `byteCount`, `lineCount`
  - `mimeHint` (text/json/diff)

- `CheckpointRef` (v1.5+)

  - `checkpointId`
  - `gitRef` (private ref namespace)
  - `messageId` (the user message it corresponds to)

### Persistence strategy (strongly recommended)

Use an **append-only event log** stored in SQLite:

- Pros: crash-safe, easy incremental updates, supports replay, supports FTS later.
- Store large tool outputs as files; store metadata in DB.

---

## 3.3 Streaming & Rendering Pipeline

### Claude Agent SDK streaming

To get typewriter-like streaming, enable partial streaming events and accumulate text deltas yourself. The Agent SDK supports `include_partial_messages=True` and yields `StreamEvent`s whose raw events include `content_block_delta` with `text_delta`.([Claude][13])

**Engineering implication:**

- Swift doesn’t need to “render character by character”; just append text chunks at ~30–60Hz.
- Don’t parse markdown on every append; do final parse on completion.

---

## 3.4 Swift↔Python Bridge Design (Option A: subprocess + JSON-RPC)

### Requirements

- Bidirectional communication (Swift sends prompts; Python streams events; Swift can send cancel/permission responses)
- Multiple sessions (at least sequential; later concurrent)
- Robust framing (line-delimited JSON)
- Backpressure safe for large outputs

### Transport

- Spawn a long-lived Python process per workspace (recommended) OR a shared process with multiple sessions.
- Use **NDJSON** on stdout for events, and **JSON-RPC 2.0** on stdin for requests.
- Each JSON object is a single line. Large outputs are never inlined; they’re stored to disk and referenced.

This mirrors the “streaming JSON, one object per line” integration pattern many coding harnesses use.([AmpCode][4])

### Message types

#### Swift → Python (JSON-RPC request)

```json
{
  "jsonrpc": "2.0",
  "id": "req_123",
  "method": "session.send",
  "params": {
    "session_id": "uuid",
    "workspace_path": "/path/to/work",
    "prompt": "Fix failing tests",
    "options": {
      "allowed_tools": [
        "Read",
        "Edit",
        "Bash",
        "Glob",
        "Grep",
        "WebFetch",
        "Task"
      ],
      "include_partial_messages": true
    }
  }
}
```

#### Python → Swift (notification events)

```json
{"type":"event","session_id":"uuid","event":"assistant.delta","text":"Okay, I’ll start by…"}
{"type":"event","session_id":"uuid","event":"tool.start","tool_use_id":"tu_1","name":"Bash","input":{"command":"npm test"}}
{"type":"event","session_id":"uuid","event":"tool.result","tool_use_id":"tu_1","result_ref":{"storage_key":"tool/tu_1.txt","preview":"...","byte_count":12345}}
{"type":"event","session_id":"uuid","event":"assistant.final"}
{"type":"event","session_id":"uuid","event":"result","subtype":"success","usage":{"input_tokens":...,"output_tokens":...}}
```

### Cancellation

- Primary: `session.cancel` request (Python cooperatively cancels current query)
- Fallback: send SIGINT to process group; then SIGKILL if stuck

### Permissions / Tool interception (critical for safety)

The Agent SDK supports hooks like `PreToolUse` and `PostToolUse` (Python) and describes built-in tool names and matchers.([Claude][14])
Implement a `PreToolUse` hook that can:

1. consult local allow rules (fast path)
2. if not allowed, emit `permission.request` event to Swift and await response

Amp’s model is a good default: allow common safe commands without prompting; confirm destructive/sensitive ones.([AmpCode][4])

---

## 3.5 Tool Output Storage & “Long Output” Handling

### Rule: never stream huge blobs into SwiftUI

When a tool produces output:

- Python writes it to a file in:

  - `~/Library/Application Support/<bundle-id>/ToolOutputs/<session>/<tool_use_id>.txt`

- Python sends only:

  - `storage_key`
  - `byte_count`, `line_count`
  - a `preview` (first N lines, capped)

Swift loads full content **only when user opens viewer**.

### Output Viewer

Use an `NSViewRepresentable` wrapping `NSTextView` for:

- fast large text rendering
- selection, copy, search, jump-to-line
  (This is one of the few justified AppKit bridges.)

---

## 3.6 Workspaces, Branches, and Parallel Agents (v1.5+)

### Workspace identity

Conductor’s model: workspace is strongly associated with a git branch; creating a workspace creates a new branch; one workspace per branch checkout; branching and switching supported.([Conductor][16])

### Recommended implementation in Smithers

- For a repo root path, create a **git worktree** per workspace:

  - `.../Smithers/Workspaces/<repoHash>/<workspaceName>/`

- Create a new branch for each workspace (`smithers/<workspaceId>`), or allow “start from branch”.
- Multiple worktrees allow parallel without checkout conflicts.

### Scripts (v2)

Replicate Conductor’s three scripts:

- setup (on workspace create)
- run (Run button)
- archive (on workspace archive)([Conductor][6])

Expose env vars similar to Conductor (`WORKSPACE_NAME`, `WORKSPACE_PATH`, `ROOT_PATH`, `DEFAULT_BRANCH`, `PORT`).([Conductor][15])

### Running multiple processes

If your run scripts spawn multiple services, use a single process group (avoid `&` backgrounding) so Stop can clean everything up—mirrors Conductor’s advice.([Conductor][17])

---

## 3.7 Checkpoints & Revert (v1.5+)

Conductor’s checkpoints semantics are very clear:

- automatic snapshots stored locally in a private git ref
- revert deletes later conversation and reverts code changes since that user message([Conductor][9])

### Smithers implementation

- Before sending each user prompt:

  - commit current state to a private ref namespace (no remote push)
  - persist a `CheckpointRef` linking to the user message id

- Revert:

  - `git reset --hard <checkpointRef>`
  - truncate session event log after that message
  - invalidate any derived artifacts (diff cache, tool outputs beyond the checkpoint)

---

## 3.8 Diff Viewer (v1.5+)

Minimal diff viewer:

- `git diff <lastCheckpoint>..HEAD`
- Show file list and unified diff with syntax coloring
- Actions:

  - Copy patch
  - Open file
  - (later) stage/unstage hunks

Conductor frames this as “review changes and sync with GitHub.”([Conductor][5])
Smithers doesn’t need to implement PR creation in v1; just make review frictionless.

---

## 3.9 Todos (v1.5+)

Match Conductor’s pattern:

- Todos live in a panel, can be user- and agent-added.
- Composer supports `@todos` to inject the checklist into the prompt context.([Conductor][8])
- Optional “workspace blocked” state if you want guardrails; can be a preference.

---

## 3.10 Slash commands & templates

Conductor supports custom slash commands as markdown files in `.claude/commands/`.([Conductor][10])
Smithers should:

- load commands from:

  - `~/.claude/commands/*.md`
  - `<workspace>/.claude/commands/*.md`
  - (optionally) `~/.smithers/commands/*.md`

- present them in the `/` command palette
- support templating variables (workspace path, selected files, etc.)

---

## 3.11 MCP integration

The Agent SDK supports MCP servers configured in code or via a `.mcp.json` file loaded automatically; tools use the naming `mcp__<server>__<tool>` and require explicit permission.([Claude][18])

Smithers should:

- detect `.mcp.json` in workspace root and surface it in UI
- provide an MCP management UI (later) akin to Amp’s configuration approach.([AmpCode][4])

---

## 3.12 Subagents and orchestration (v2)

Amp’s model: subagents have their own context and tools, and the main agent receives a final summary.([AmpCode][4])
The Agent SDK also supports subagent-related hooks/events (e.g., `SubagentStart/Stop` in docs) to track spawning and completion.([Claude][14])

UI plan:

- render subagent runs as collapsible “Subagent” cards inside the transcript
- allow “Open as separate session” if you later want deeper inspection

---

## 3.13 Milestone plan (what to build first)

### Milestone 1 — Production-quality transcript

- New message model + event store
- Streaming assistant text
- Tool cards + long-output viewer
- Stop/cancel
- Sidebar session UX (search, preview, rename/delete)

### Milestone 2 — Workspace binding + terminal ergonomics

- Open folder workflow
- Bash tool runs in that directory
- Optional integrated terminal pane for run output

### Milestone 3 — Diff + checkpoints

- git detection
- checkpoint commits + revert
- diff viewer

### Milestone 4 — Commands, todos, permissions

- slash command palette (load `.claude/commands`)
- todos panel + `@todos`
- permission gating (PreToolUse hook + Swift approval sheet)

### Milestone 5 — MCP & extensibility

- `.mcp.json` UI visibility
- tool registry and per-tool permissions
- “skills”/profiles system (agent presets)

---

## 3.14 Key engineering risks & mitigations

1. **Markdown rendering performance**
   Mitigation: streaming as plain text; finalize render once; cache rendered attributed strings.

2. **Large tool outputs**
   Mitigation: disk-backed output refs + preview-only in transcript.

3. **Bidirectional permission prompts**
   Mitigation: JSON-RPC protocol with async “permission.request” and “permission.response”; timeouts + safe defaults.

4. **Parallel workspaces and git correctness**
   Mitigation: git worktrees; strict workspace lifecycle; archive script hooks (Conductor-style).([Conductor][6])

5. **`libghostty` API stability** (future)
   Ghostty docs note `libghostty` API stability is a goal but not historically stable as a standalone API; plan for wrappers and version gating.([Ghostty][1])

---

If you want this to be “deploy-many-devs-ready,” the highest leverage next step is to treat the **Swift↔Python event protocol + persistence/event-log** as the first “platform layer.” Once that’s stable, UI improvements, diffs/checkpoints, MCP, and multi-agent orchestration become additive rather than rewrites.

[1]: https://ghostty.org/docs/about "About Ghostty"
[2]: https://docs.conductor.build/core/parallel-agents "https://docs.conductor.build/core/parallel-agents"
[3]: https://shittycodingagent.ai/ "https://shittycodingagent.ai/"
[4]: https://ampcode.com/manual "https://ampcode.com/manual"
[5]: https://docs.conductor.build/core/diff-viewer "https://docs.conductor.build/core/diff-viewer"
[6]: https://docs.conductor.build/core/scripts "https://docs.conductor.build/core/scripts"
[7]: https://docs.conductor.build/core/testing "https://docs.conductor.build/core/testing"
[8]: https://docs.conductor.build/core/todos "https://docs.conductor.build/core/todos"
[9]: https://docs.conductor.build/core/checkpoints "https://docs.conductor.build/core/checkpoints"
[10]: https://docs.conductor.build/core/slash-commands "https://docs.conductor.build/core/slash-commands"
[11]: https://docs.conductor.build/core/mcp "https://docs.conductor.build/core/mcp"
[12]: https://docs.conductor.build/workflow "https://docs.conductor.build/workflow"
[13]: https://platform.claude.com/docs/en/agent-sdk/streaming-output "Stream responses in real-time - Claude API Docs"
[14]: https://platform.claude.com/docs/en/agent-sdk/hooks "Intercept and control agent behavior with hooks - Claude API Docs"
[15]: https://docs.conductor.build/tips/conductor-env "Conductor environment variables - Conductor"
[16]: https://docs.conductor.build/tips/workspaces-and-branches "Workspaces and branches - Conductor"
[17]: https://docs.conductor.build/tips/multiple-processes "Running multiple processes - Conductor"
[18]: https://platform.claude.com/docs/en/agent-sdk/mcp "Connect to external tools with MCP - Claude API Docs"
