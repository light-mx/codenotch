using System;

namespace Codenotch.Models;

/// <summary>
/// Represents a session of an agent.
/// </summary>
public record AgentSession(
    string Id,
    string Name,
    string Detail,
    AgentSession.SessionState State,
    string? WaitingFor,
    DateTime Since)
{
    public enum SessionState
    {
        Busy,
        Waiting,
        Idle
    }

    public bool IsActive => State == SessionState.Busy || State == SessionState.Waiting;
}
