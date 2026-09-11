using System.Collections.Generic;
using System.Text.Json;
using Microsoft.Maui.Storage;
using Codenotch.Models;

namespace Codenotch.Services;

public interface IPreferences
{
    HashSet<string> DisconnectedProviders { get; set; }
    NotchVisibility NotchVisibility { get; set; }
    NotchEdge NotchEdge { get; set; }
    AppPresence AppPresence { get; set; }
    bool LaunchAtLogin { get; set; }
    string LastSeenVersion { get; set; }
}

public class AppPreferences : IPreferences
{
    private readonly Microsoft.Maui.Storage.IPreferences _prefs;

    public AppPreferences(Microsoft.Maui.Storage.IPreferences? prefs = null)
    {
        _prefs = prefs ?? Microsoft.Maui.Storage.Preferences.Default;
    }

    public HashSet<string> DisconnectedProviders
    {
        get
        {
            var json = _prefs.Get(nameof(DisconnectedProviders), "[]");
            return JsonSerializer.Deserialize<HashSet<string>>(json) ?? new HashSet<string>();
        }
        set
        {
            var json = JsonSerializer.Serialize(value);
            _prefs.Set(nameof(DisconnectedProviders), json);
        }
    }

    public NotchVisibility NotchVisibility
    {
        get => (NotchVisibility)_prefs.Get(nameof(NotchVisibility), (int)NotchVisibility.AlwaysShow);
        set => _prefs.Set(nameof(NotchVisibility), (int)value);
    }

    public NotchEdge NotchEdge
    {
        get => (NotchEdge)_prefs.Get(nameof(NotchEdge), (int)NotchEdge.Right);
        set => _prefs.Set(nameof(NotchEdge), (int)value);
    }

    public AppPresence AppPresence
    {
        get => (AppPresence)_prefs.Get(nameof(AppPresence), (int)AppPresence.Dock);
        set => _prefs.Set(nameof(AppPresence), (int)value);
    }

    public bool LaunchAtLogin
    {
        get => _prefs.Get(nameof(LaunchAtLogin), false);
        set => _prefs.Set(nameof(LaunchAtLogin), value);
    }

    public string LastSeenVersion
    {
        get => _prefs.Get(nameof(LastSeenVersion), "");
        set => _prefs.Set(nameof(LastSeenVersion), value);
    }
}
