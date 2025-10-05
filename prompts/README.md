# Guillotine EVM Audit Pipeline

Automated agent-based audit system for the Guillotine EVM implementation, comparing against the Python execution-specs Prague reference.

## Setup

```bash
cd scripts
bun install  # Already done
```

Make sure you have `ANTHROPIC_API_KEY` set in your environment:

```bash
export ANTHROPIC_API_KEY="your-key-here"
```

## Usage

### Run All Phases

```bash
cd scripts
bun run index.ts
```

This will:
1. Run Phase 1 agents (Primitives, State Management) in parallel
2. Run Phase 2 agents (Opcodes) in parallel after Phase 1 completes
3. Continue through all phases sequentially
4. Generate reports in `reports/` directory
5. Create a summary report with costs and findings

### Run Specific Phase

```bash
# Run just Phase 1 (Foundation)
bun run index.ts phase 1

# Run just Phase 2 (Opcodes)
bun run index.ts phase 2
```

### Run Single Agent

```bash
# Run just the primitives auditor
bun run index.ts agent agent1

# Run just the system calls auditor
bun run index.ts agent agent11
```

## Current Agents

### Phase 1: Foundation
- **agent1**: Primitives Auditor - Audits `src/primitives/` (gas constants, U256, transactions, etc.)
- **agent2**: State Management Auditor - Audits state tracking, access lists, transient storage

### Phase 2: Opcodes (In Progress)
- **agent11**: System Call Opcodes Auditor - Audits CREATE, CALL family, SELFDESTRUCT (most critical)

## Adding More Agents

1. Create a prompt file in `prompts/`:
   ```bash
   cp prompts/phase1-agent1-primitives.md prompts/phase2-agent3-arithmetic.md
   ```

2. Edit the prompt file with specific audit instructions

3. Add the agent to `AGENTS` array in `scripts/index.ts`:
   ```typescript
   {
     id: 'agent3',
     name: 'Arithmetic Opcodes Auditor',
     promptFile: 'prompts/phase2-agent3-arithmetic.md',
     phase: 2,
     dependsOn: ['agent1'], // Optional
     outputFile: 'reports/phase2-agent3-arithmetic-report.md',
   },
   ```

4. Run it:
   ```bash
   bun run index.ts agent agent3
   ```

## Output

All reports are saved to `reports/`:

```
reports/
├── phase1-agent1-primitives-report.md
├── phase1-agent2-state-management-report.md
├── phase2-agent11-system-calls-report.md
└── pipeline-summary.md  # Overall summary with costs
```

## Prompt Template Structure

Each prompt file should include:

1. **Objective**: What the agent should audit
2. **Scope**: Which files to examine
3. **Reference**: Python spec files to compare against
4. **Checklist**: Specific items to verify
5. **Output Format**: Template for the markdown report

See `prompts/phase1-agent1-primitives.md` for a complete example.

## Example Workflow

```bash
# 1. Run foundation audit
bun run index.ts phase 1

# 2. Review reports
cat ../reports/phase1-agent1-primitives-report.md
cat ../reports/phase1-agent2-state-management-report.md

# 3. Fix critical issues found

# 4. Run opcode audits
bun run index.ts phase 2

# 5. Fix issues, iterate

# 6. Eventually run test infrastructure setup
bun run index.ts phase 4

# 7. Run test validation
bun run index.ts phase 5
```

## Cost Estimation

Rough estimates per agent (using Claude Sonnet 4.5):
- Simple audits (arithmetic opcodes): ~$0.10-0.20
- Medium audits (state management): ~$0.30-0.50
- Complex audits (system calls): ~$0.50-1.00

Full pipeline (all agents): ~$10-15

## Agent Features

Each agent can:
- **Read**: Examine Zig and Python source files
- **Grep**: Search for patterns and constants
- **Bash**: Run commands for verification
- **Multi-turn**: Up to 30 turns for thorough analysis

Agents automatically:
- Compare Zig implementation against Python spec
- Identify missing features
- Flag incorrect implementations
- Provide line numbers and specific fixes
- Prioritize issues (CRITICAL, HIGH, MEDIUM, LOW)

## Next Steps

After completing the audit phases:

1. **Implement Fixes**: Address CRITICAL and HIGH priority issues
2. **Test Infrastructure** (Phase 4): Fix test runner to work with `fill` output
3. **Test Validation** (Phase 5): Run official execution-specs tests
4. **Iterate**: Fix bugs found by tests, re-run agents as needed

## Tips

- Run single agents first to verify setup
- Review outputs to ensure quality before running all phases
- Agents run in parallel within phases for speed
- Each agent is stateless and independent
- Reports are comprehensive markdown files
