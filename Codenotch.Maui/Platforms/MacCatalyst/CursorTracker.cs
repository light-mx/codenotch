#if MACCATALYST
using System.Timers;

namespace Codenotch.Platforms.MacCatalyst;

/// <summary>
/// Tracks cursor positioning and provides hover detection state.
/// </summary>
public class CursorTracker : IDisposable
{
    private readonly System.Timers.Timer _pollTimer;
    public event Action<double, double>? CursorMoved;

    public CursorTracker(double intervalMs = 150)
    {
        _pollTimer = new System.Timers.Timer(intervalMs);
        _pollTimer.Elapsed += OnPoll;
    }

    public void Start() => _pollTimer.Start();
    public void Stop() => _pollTimer.Stop();

    private void OnPoll(object? sender, ElapsedEventArgs e)
    {
        // Polling loop for desktop hover state if required
    }

    public void Dispose()
    {
        _pollTimer.Dispose();
    }
}
#endif
