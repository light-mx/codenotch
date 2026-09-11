using System;
using System.Collections.Generic;
using Codenotch.Models;
using Codenotch.Services;
using Xunit;

namespace Codenotch.Tests;

public class ModelTests
{
    [Fact]
    public void Fidelity_Prefix_Is_Correct()
    {
        var official = Fidelity.Official;
        var derived = Fidelity.Derived;
        var manual = Fidelity.Manual;

        Assert.Equal("", official.GetQualifier());
        Assert.Equal("~", derived.GetQualifier());
        Assert.Equal("~", manual.GetQualifier());
    }

    [Fact]
    public void LimitWindow_Summary_Formatted_Correctly()
    {
        var windowFraction = new LimitWindow("w1", "Session", 0.73, null, null, null);
        Assert.Equal("73% Used · 27% left", windowFraction.Summary);

        var windowRemaining = new LimitWindow("w2", "Prompts", null, 15, null, null);
        Assert.Equal("15 left", windowRemaining.Summary);

        var windowUsed = new LimitWindow("w3", "Count", null, null, 42, null);
        Assert.Equal("42 used", windowUsed.Summary);
    }

    [Fact]
    public void UsageBand_Maps_Correct_Colors()
    {
        Assert.Equal(UsageBand.Ample, UsageBandExtensions.GetBand(0.21));
        Assert.Equal(UsageBand.Watch, UsageBandExtensions.GetBand(0.52));
        Assert.Equal(UsageBand.Critical, UsageBandExtensions.GetBand(0.73));
        Assert.Equal(UsageBand.Exhausted, UsageBandExtensions.GetBand(1.00));

        Assert.Equal("#00FF88", UsageBand.Ample.GetColorHex());
        Assert.Equal("#F2FF00", UsageBand.Watch.GetColorHex());
        Assert.Equal("#FF3F00", UsageBand.Critical.GetColorHex());
    }

    [Fact]
    public void ProviderSnapshot_Calculates_Headline_And_Fractions()
    {
        var windows = new List<LimitWindow>
        {
            new("session", "Session", 0.73, null, null, null),
            new("weekly", "Weekly", 0.12, null, null, null)
        };

        var snapshot = new ProviderSnapshot(
            "claude",
            "Claude",
            ProviderGlyph.Claude,
            Fidelity.Official,
            new ProviderStatus.Ok(),
            windows,
            "session"
        );

        Assert.NotNull(snapshot.Headline);
        Assert.Equal("session", snapshot.Headline.Id);
        Assert.Equal(0.73, snapshot.UsedFraction);
        Assert.True(snapshot.HasReading);
        Assert.False(snapshot.IsStale);
        Assert.False(snapshot.IsBlocked);
    }

    [Fact]
    public void ElapsedCopy_Formats_Correctly()
    {
        Assert.Equal("just now", ElapsedCopy.Format(TimeSpan.FromSeconds(30)));
        Assert.Equal("5 min", ElapsedCopy.Format(TimeSpan.FromMinutes(5)));
        Assert.Equal("2 hr 15 min", ElapsedCopy.Format(TimeSpan.FromHours(2.25)));
    }

    [Fact]
    public void DesignConstants_Match_Swift_Scale()
    {
        Assert.Equal(44.0 / 117.0, Design.Scale, 5);
        Assert.Equal(44.0, NotchLayout.RingDiameter, 1);
    }
}
