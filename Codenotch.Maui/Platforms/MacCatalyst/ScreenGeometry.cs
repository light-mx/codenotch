#if MACCATALYST
using Codenotch.Models;
using UIKit;

namespace Codenotch.Platforms.MacCatalyst;

/// <summary>
/// Screen positioning maths converted from NotchGeometry.swift.
/// Positions the notch window relative to display bounds and visible frame (dock/menu bar).
/// </summary>
public static class ScreenGeometry
{
    public record Rect(double X, double Y, double Width, double Height)
    {
        public double MidX => X + Width / 2;
        public double MidY => Y + Height / 2;
        public double MaxX => X + Width;
        public double MaxY => Y + Height;
    }

    /// <summary>
    /// Calculates window frame hugging chosen screen edge, centered along it.
    /// </summary>
    public static Rect CalculatePanelFrame(
        Rect fullScreen,
        Rect usableScreen,
        double panelWidth,
        double panelHeight,
        NotchEdge edge,
        HardwareNotch? hardwareNotch = null)
    {
        double width = Math.Ceiling(panelWidth);
        double height = Math.Ceiling(panelHeight);

        double x = 0;
        double y = 0;

        switch (edge)
        {
            case NotchEdge.Right:
                x = usableScreen.MaxX - width;
                y = fullScreen.MidY - height / 2;
                break;

            case NotchEdge.Left:
                x = usableScreen.X;
                y = fullScreen.MidY - height / 2;
                break;

            case NotchEdge.Top:
                double top = hardwareNotch == null ? usableScreen.MaxY : fullScreen.MaxY;
                x = fullScreen.MidX - width / 2;
                y = top - height;
                break;

            case NotchEdge.Bottom:
                x = fullScreen.MidX - width / 2;
                y = usableScreen.Y;
                break;
        }

        return new Rect(Math.Round(x), Math.Round(y), width, height);
    }
}
#endif
