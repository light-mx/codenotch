using System;
using System.Collections.Generic;
using System.Linq;
using CommunityToolkit.Mvvm.ComponentModel;
using Codenotch.Models;

namespace Codenotch.Services;

public partial class NotchViewModel : ObservableObject
{
    [ObservableProperty] private List<ProviderSnapshot> _snapshots = new();
    [ObservableProperty] private Dictionary<string, List<AgentSession>> _sessions = new();
    [ObservableProperty] private int? _hoveredIndex;
    [ObservableProperty] private bool _isExpanded;
    [ObservableProperty] private bool _isPinned;
    [ObservableProperty] private bool _isAlwaysOn;
    [ObservableProperty] private NotchEdge _edge = NotchEdge.Right;
    [ObservableProperty] private HashSet<string> _refreshing = new();
    [ObservableProperty] private DateTime _now = DateTime.UtcNow;
    [ObservableProperty] private HardwareNotch? _hardwareNotch;

    public int CellCount => Snapshots.Count;

    public ProviderSnapshot? HoveredSnapshot => 
        HoveredIndex.HasValue && HoveredIndex.Value >= 0 && HoveredIndex.Value < Snapshots.Count 
            ? Snapshots[HoveredIndex.Value] 
            : null;

    public bool ActivityForProvider(string id)
    {
        return Refreshing.Contains(id) || (Sessions.TryGetValue(id, out var sessions) && sessions.Any(s => s.IsActive));
    }
}
