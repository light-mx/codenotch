namespace Codenotch.Models;

/// <summary>
/// Summarizes the activity states of agents.
/// </summary>
public record ActivitySummary(ActivitySummary.ActivityState State, int Count)
{
    public enum ActivityState
    {
        None = 0,
        Working,
        Waiting,
        Idle
    }
}
