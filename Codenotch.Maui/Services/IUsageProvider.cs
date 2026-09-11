using System;
using System.Threading.Tasks;
using Codenotch.Models;

namespace Codenotch.Services;

public interface IUsageProvider
{
    string Id { get; }
    string DisplayName { get; }
    ProviderGlyph Glyph { get; }
    Task<ProviderSnapshot> FetchSnapshotAsync();
    ProviderAccount? Account();
    SignInRoute SignInRoute { get; }
    Task SignOutAsync();
    void PresentSignIn();
    void ForgetCachedCredential();
}

public class UsageProviderException : Exception
{
    public ProviderErrorType ErrorType { get; }

    public UsageProviderException(ProviderErrorType errorType, string message) : base(message)
    {
        ErrorType = errorType;
    }

    public UsageProviderException(ProviderErrorType errorType, string message, Exception innerException) : base(message, innerException)
    {
        ErrorType = errorType;
    }
}

public enum ProviderErrorType
{
    Network,
    Authentication,
    Parsing,
    RateLimit,
    Unknown
}
