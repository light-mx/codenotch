namespace Codenotch.Models;

/// <summary>
/// Represents the fidelity of a usage reading.
/// </summary>
public enum Fidelity
{
    Official,
    Derived,
    Manual
}

public static class FidelityExtensions
{
    /// <summary>
    /// Gets a qualifier string for the fidelity. Empty for official, "~" otherwise.
    /// </summary>
    public static string GetQualifier(this Fidelity fidelity) => fidelity == Fidelity.Official ? "" : "~";
}
