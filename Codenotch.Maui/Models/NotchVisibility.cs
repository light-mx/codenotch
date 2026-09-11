namespace Codenotch.Models;

/// <summary>
/// When the notch appears on screen.
/// Converted from Settings/NotchVisibility.swift.
/// </summary>
public enum NotchVisibility
{
    AlwaysShow,
    OnHover,
    Hidden
}

public static class NotchVisibilityExtensions
{
    public static string Title(this NotchVisibility visibility) => visibility switch
    {
        NotchVisibility.AlwaysShow => "Always",
        NotchVisibility.OnHover => "On hover",
        NotchVisibility.Hidden => "Hidden",
        _ => visibility.ToString()
    };

    public static string Explanation(this NotchVisibility visibility) => visibility switch
    {
        NotchVisibility.AlwaysShow => "Stays on screen, readings visible all the time.",
        NotchVisibility.OnHover => "Folds into a narrow black pill at the edge until you move the pointer over it.",
        NotchVisibility.Hidden => "Removes the notch entirely.",
        _ => string.Empty
    };
}
