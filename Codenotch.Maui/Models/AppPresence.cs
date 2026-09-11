namespace Codenotch.Models;

/// <summary>
/// Where Codenotch appears in macOS UI.
/// Converted from Settings/AppPresence.swift.
/// </summary>
public enum AppPresence
{
    Dock,
    MenuBar,
    Hidden
}

public static class AppPresenceExtensions
{
    public static string Title(this AppPresence presence) => presence switch
    {
        AppPresence.Dock => "Dock",
        AppPresence.MenuBar => "Menu bar",
        AppPresence.Hidden => "Neither",
        _ => presence.ToString()
    };

    public static string Explanation(this AppPresence presence) => presence switch
    {
        AppPresence.Dock => "An icon in the Dock, as normal. Quitting from the Dock quits Codenotch.",
        AppPresence.MenuBar => "A small icon in the menu bar. Clicking it opens Settings.",
        AppPresence.Hidden => "No icons anywhere. Reopening Codenotch from Applications or Spotlight brings up Settings.",
        _ => string.Empty
    };
}
