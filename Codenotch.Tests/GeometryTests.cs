using Codenotch.Models;
using Xunit;

namespace Codenotch.Tests;

public class GeometryTests
{
    // ScreenGeometry standalone math tests
    public record ScreenRect(double X, double Y, double Width, double Height)
    {
        public double MidX => X + Width / 2;
        public double MidY => Y + Height / 2;
        public double MaxX => X + Width;
        public double MaxY => Y + Height;
    }

    private static ScreenRect CalculatePlacement(
        ScreenRect fullScreen,
        ScreenRect usableScreen,
        double panelWidth,
        double panelHeight,
        NotchEdge edge)
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
                x = fullScreen.MidX - width / 2;
                y = fullScreen.MaxY - height;
                break;

            case NotchEdge.Bottom:
                x = fullScreen.MidX - width / 2;
                y = usableScreen.Y;
                break;
        }

        return new ScreenRect(Math.Round(x), Math.Round(y), width, height);
    }

    [Fact]
    public void RightEdge_Hugs_Visible_Right_Bezel()
    {
        var full = new ScreenRect(0, 0, 1920, 1080);
        var usable = new ScreenRect(0, 60, 1920, 1020); // Bottom dock
        double panelWidth = 70;
        double panelHeight = 250;

        var panel = CalculatePlacement(full, usable, panelWidth, panelHeight, NotchEdge.Right);

        Assert.Equal(1850, panel.X); // 1920 - 70
        Assert.Equal(1080 / 2 - 125, panel.Y); // Vertically centered on full screen
        Assert.Equal(70, panel.Width);
        Assert.Equal(250, panel.Height);
    }

    [Fact]
    public void LeftEdge_Hugs_Visible_Left_Bezel()
    {
        var full = new ScreenRect(0, 0, 1920, 1080);
        var usable = new ScreenRect(80, 0, 1840, 1080); // Left dock
        double panelWidth = 70;
        double panelHeight = 250;

        var panel = CalculatePlacement(full, usable, panelWidth, panelHeight, NotchEdge.Left);

        Assert.Equal(80, panel.X); // Hugs visible dock boundary
        Assert.Equal(1080 / 2 - 125, panel.Y);
    }

    [Fact]
    public void TopEdge_Hugs_Top_Bezel_And_Centers_Horizontally()
    {
        var full = new ScreenRect(0, 0, 1920, 1080);
        var usable = new ScreenRect(0, 0, 1920, 1055);
        double panelWidth = 350;
        double panelHeight = 44;

        var panel = CalculatePlacement(full, usable, panelWidth, panelHeight, NotchEdge.Top);

        Assert.Equal(1920 / 2 - 175, panel.X);
        Assert.Equal(1080 - 44, panel.Y);
    }
}
