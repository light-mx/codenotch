using System;
using Microsoft.AspNetCore.Components;
using Codenotch.Models;

namespace Codenotch.Components.Shared;

public partial class LimitWindowRow : ComponentBase
{
    [Parameter]
    public LimitWindow WindowItem { get; set; } = default!;

    [Parameter]
    public DateTime Now { get; set; }

    public double UsedFraction => Math.Clamp(WindowItem?.UsedFraction ?? 0, 0, 1);

    public string BandClass => UsedFraction switch
    {
        < 0.50 => "ample",
        < 0.70 => "watch",
        _ => "critical"
    };
}
