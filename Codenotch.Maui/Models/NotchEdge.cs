namespace Codenotch.Models;

/// <summary>
/// Defines which edge of the screen the notch is on.
/// </summary>
public enum NotchEdge
{
    Right,
    Left,
    Top,
    Bottom
}

public static class NotchEdgeExtensions
{
    public static bool IsVertical(this NotchEdge edge) => edge == NotchEdge.Right || edge == NotchEdge.Left;

    public enum TooltipDirection
    {
        Leading,
        Trailing,
        Up,
        Down
    }

    public static TooltipDirection GetTooltipDirection(this NotchEdge edge)
    {
        return edge switch
        {
            NotchEdge.Right => TooltipDirection.Leading,
            NotchEdge.Left => TooltipDirection.Trailing,
            NotchEdge.Top => TooltipDirection.Down,
            NotchEdge.Bottom => TooltipDirection.Up,
            _ => TooltipDirection.Leading
        };
    }

    public static string GetTitle(this NotchEdge edge)
    {
        return edge switch
        {
            NotchEdge.Right => "Right Edge",
            NotchEdge.Left => "Left Edge",
            NotchEdge.Top => "Top Edge",
            NotchEdge.Bottom => "Bottom Edge",
            _ => edge.ToString()
        };
    }

    public static string GetExplanation(this NotchEdge edge)
    {
        return $"Snap to {edge.GetTitle().ToLower()}";
    }
}
