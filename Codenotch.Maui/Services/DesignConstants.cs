namespace Codenotch.Services;

public static class Design
{
    public const double Scale = 44.0 / 117.0;  // 0.376...
    public static double Px(double figmaPixels) => figmaPixels * Scale;
    public static double FontSize(double capPixels) => capPixels * Scale / 0.714;
}

public static class NotchLayout
{
    public static readonly double RingDiameter = 44;
    public static readonly double RingStroke = Design.Px(16);
    public static readonly double TrackStroke = Design.Px(16);
    public static readonly double SideBodyDepth = 70;
    public static readonly double PillWidth = 9.8;
    public static readonly double PillHeight = 79;
    public static readonly double CellWidth = 44;
    public static readonly double CellHeight = 44;
    public static readonly double Spacing = 8;
    public static readonly double Padding = 12;
}
