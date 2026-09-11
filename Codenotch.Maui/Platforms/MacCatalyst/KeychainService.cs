#if MACCATALYST
using System.Diagnostics;

namespace Codenotch.Platforms.MacCatalyst;

/// <summary>
/// Service to read credentials from the macOS login keychain
/// (e.g. Claude Code or Antigravity auth tokens).
/// </summary>
public static class KeychainService
{
    /// <summary>
    /// Reads a generic password from macOS keychain using the security CLI.
    /// Matches KeychainItem.swift behavior.
    /// </summary>
    public static string? ReadGenericPassword(string serviceName, string? accountName = null)
    {
        try
        {
            var args = $"-s \"{serviceName}\" -w";
            if (!string.IsNullOrEmpty(accountName))
            {
                args = $"-a \"{accountName}\" " + args;
            }

            var psi = new ProcessStartInfo
            {
                FileName = "/usr/bin/security",
                Arguments = "find-generic-password " + args,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                UseShellExecute = false,
                CreateNoWindow = true
            };

            using var process = Process.Start(psi);
            if (process == null) return null;

            var output = process.StandardOutput.ReadToEnd().Trim();
            process.WaitForExit();

            return process.ExitCode == 0 ? output : null;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[Codenotch] Keychain read error: {ex.Message}");
            return null;
        }
    }
}
#endif
