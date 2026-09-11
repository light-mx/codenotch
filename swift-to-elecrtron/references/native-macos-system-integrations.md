# Native macOS System Integrations in Electron

This document covers accessing macOS Keychain passwords, reading application SQLite state databases in WAL mode, detecting process liveness, and registering login items without external C++ compilation dependencies.

---

## 1. macOS Keychain Access

### Reading Generic Passwords via `/usr/bin/security`
macOS bundles the `/usr/bin/security` utility. It can query Keychain items without requiring native binary rebuilds (`node-gyp` or deprecated `keytar`).

```typescript
import { execFileSync } from 'child_process';

export function readKeychainPassword(service: String, account?: string): string | null {
  try {
    const args = ['find-generic-password', '-s', service];
    if (account) args.push('-a', account);
    args.push('-w'); // -w outputs the password data directly

    const stdout = execFileSync('/usr/bin/security', args, {
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'ignore']
    });

    return stdout.trim();
  } catch (err: any) {
    // Exit code 44 means item not found; exit code 128 means user cancelled prompt
    return null;
  }
}
```

### Checking Modification Timestamps
To prevent repeated user prompts on every poll, check the item's modification timestamp:
```typescript
export function getKeychainItemModifiedDate(service: string): Date | null {
  try {
    const stdout = execFileSync('/usr/bin/security', ['find-generic-password', '-s', service], {
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'ignore']
    });
    const match = stdout.match(/"mdat"<blob>="([^"]+)"/);
    if (match) return new Date(match[1]);
  } catch {}
  return null;
}
```

---

## 2. Reading SQLite State in WAL Mode

Tools like Cursor and VS Code store active workspace sessions in SQLite (`state.vscdb`) configured in Write-Ahead Logging (`WAL`) mode.

If you query with `immutable=1`, SQLite will ignore recent uncheckpointed writes. Instead:
- Open the database with read-only flag `SQLITE_OPEN_READONLY`.
- Do not set `immutable=1`.
- Always close connections promptly.

```typescript
import Database from 'better-sqlite3';

export function readCursorSession(dbPath: string): { accessToken: string; accountId: string } | null {
  try {
    const db = new Database(dbPath, { readonly: true, fileMustExist: true });
    const row = db.prepare("SELECT value FROM ItemTable WHERE key = 'cursorAuth/accessToken'").get() as { value: string };
    const accountRow = db.prepare("SELECT value FROM ItemTable WHERE key = 'cursorAuth/stripeMembershipAuthId'").get() as { value: string };
    db.close();

    if (row && accountRow) {
      return { accessToken: row.value, accountId: accountRow.value };
    }
  } catch (err) {
    console.error('Failed to read Cursor SQLite store:', err);
  }
  return null;
}
```

---

## 3. Process Liveness Verification

To determine if an agent or background assistant process is currently alive:

```typescript
export function isProcessAlive(pid: number): boolean {
  try {
    // Sending signal 0 does not kill the process; it performs an error check
    process.kill(pid, 0);
    return true;
  } catch (err: any) {
    return err.code === 'EPERM'; // EPERM means process exists, owned by another user/root
  }
}
```

---

## 4. Launch at Login

Electron provides built-in support for registering the application with macOS `ServiceManagement`:

```typescript
import { app } from 'electron';

export function setLaunchAtLogin(enabled: boolean): void {
  app.setLoginItemSettings({
    openAtLogin: enabled,
    openAsHidden: true
  });
}

export function isLaunchAtLoginEnabled(): boolean {
  return app.getLoginItemSettings().openAtLogin;
}
```
