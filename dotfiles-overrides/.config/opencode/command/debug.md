---
description: Systematic troubleshooting workflow for debugging issues
agent: debug-morgan
---
# Context

Read the user's problem or question:
- [ ] Read $ARGUMENTS

## Workflow

### Phase 1: Problem Statement

Get clear problem description:
- **What's broken?** Specific behavior or error
- **Expected vs actual:** What should happen vs what happens
- **When started:** Did something change recently?
- **Reproduction:** Reliable steps to trigger issue

### Phase 2: Gather Evidence

#### Check Processes
```bash
# Look for multiple instances
ps aux | grep [service-name]

# Check running services
systemctl status [service]
```

#### Check Logs
```bash
# Recent system logs
journalctl -n 100 --no-pager

# Service-specific logs
journalctl -u [service] -n 50 --no-pager

# Application logs
tail -50 /path/to/app.log
```

#### Check Configuration
```bash
# Find all config files
find /etc /home -name "*service*conf" 2>/dev/null

# Check which configs are loaded
[service] --show-config
```

#### Check Recent Changes
```bash
# Recent file modifications
find /path -type f -mtime -1

# Git history if applicable
git log --oneline -10
```

### Phase 3: Form Hypothesis

Based on evidence, identify likely causes:

1. **List observations:**
   - Process count: X instances running (expected: 1)
   - Log shows: "error: connection refused"
   - Config at: /etc/service.conf modified 2 hours ago

2. **Generate hypotheses:**
   - H1: Multiple instances competing for resource
   - H2: Config change broke connection
   - H3: Dependency service not running

3. **Rank by likelihood** based on evidence

### Phase 4: Test Hypotheses

For each hypothesis (highest likelihood first):

1. **Design test:**
   ```bash
   # Test H1: Check if killing extra processes fixes issue
   pkill -f [service-pattern]
   systemctl start [service]
   # Verify: Expected behavior returns?
   ```

2. **Execute test** using bash tool

3. **Record result:**
   - ✓ Confirmed: Issue resolved when [action taken]
   - ✗ Ruled out: Issue persists after [action taken]

### Phase 5: Root Cause Analysis

Once hypothesis confirmed:

1. **Why did this occur?**
   - Immediate cause: Multiple instances launched
   - Root cause: Config loads service on two separate triggers

2. **Why wasn't it caught earlier?**
   - No monitoring for duplicate processes
   - Service doesn't fail, just behaves incorrectly

### Phase 6: Provide Fix

Structure fix with:

#### Immediate Fix (stop the bleeding)
```bash
# Kill duplicate processes
pkill -f [service-pattern]

# Restart cleanly
systemctl restart [service]

# Verify fix
[verification command]
```

#### Permanent Fix (prevent recurrence)
```bash
# Modify config to prevent duplicate launch
# OR add service file with conflict detection
# OR implement monitoring check
```

#### Verification
```bash
# Test that issue is resolved
[test command]

# Test that fix persists after reboot/restart
[test command]
```

### Phase 7: Report Findings

Use this format:

```markdown
## Debug Report

**Issue:** [One line problem description]
**Root Cause:** [Specific cause identified]

### Investigation Steps
1. [Step 1] → [Finding]
2. [Step 2] → [Finding]
3. [Step 3] → [Finding]

### Evidence
- [Key log excerpt or command output]
- [Config file showing issue]
- [Process list showing duplicates]

### Root Cause
[Detailed explanation of why problem occurs]

### Fix Applied

**Immediate:**
[Commands executed to stop issue]

**Permanent:**
[Changes to prevent recurrence]

### Verification
[Commands run + outputs showing fix works]

### Prevention
[How to avoid this in future - monitoring, checks, etc.]
```

## Debugging Patterns

### Service Not Starting
1. Check service status: `systemctl status [service]`
2. Check logs: `journalctl -u [service] -n 50`
3. Check dependencies: `systemctl list-dependencies [service]`
4. Check permissions: `ls -l /path/to/service/files`
5. Try manual start: `[service-binary] --verbose`

### Multiple Instances
1. Count processes: `ps aux | grep [service] | wc -l`
2. Kill all: `pkill -f [service-pattern]`
3. Check autostart configs: `grep -r [service] ~/.config/autostart /etc/xdg/autostart`
4. Restart cleanly: Use system restart tool
5. Verify single instance: `ps aux | grep [service]`

### Configuration Issues
1. Find all configs: `find / -name "[service].conf" 2>/dev/null`
2. Check load order: `[service] --show-config`
3. Test with minimal config: Move configs aside, test defaults
4. Binary search: Remove half of config, test, repeat
5. Validate syntax: Use config validator if available

### Performance Issues
1. Check resource usage: `top` or `htop`
2. Check I/O: `iotop`
3. Check network: `netstat -tunlp`
4. Profile if needed: `strace -c [command]`
5. Check system limits: `ulimit -a`
