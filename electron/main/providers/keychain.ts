import { execFileSync } from 'child_process';

export class Keychain {
  /**
   * Reads a generic password from macOS login keychain.
   * Returns null if item is not found or user cancels.
   */
  static readGenericPassword(service: string, account?: string): string | null {
    try {
      const args = ['find-generic-password', '-s', service];
      if (account) {
        args.push('-a', account);
      }
      args.push('-w'); // -w outputs the password string directly

      const output = execFileSync('/usr/bin/security', args, {
        encoding: 'utf8',
        stdio: ['ignore', 'pipe', 'ignore'],
        timeout: 5000
      });

      return output.trim();
    } catch {
      return null;
    }
  }

  /**
   * Gets the modification date of a keychain item without prompting for the password.
   */
  static getModifiedDate(service: string, account?: string): Date | null {
    try {
      const args = ['find-generic-password', '-s', service];
      if (account) args.push('-a', account);

      const output = execFileSync('/usr/bin/security', args, {
        encoding: 'utf8',
        stdio: ['ignore', 'pipe', 'ignore'],
        timeout: 5000
      });

      const match = output.match(/"mdat"<blob>="([^"]+)"/);
      if (match) {
        return new Date(match[1]);
      }
    } catch {}
    return null;
  }
}
