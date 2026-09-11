using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Codenotch.Models;

namespace Codenotch.Services;

public class UsageStore : IDisposable
{
    private readonly IEnumerable<IUsageProvider> _providers;
    private readonly UsageArchive _archive;
    private readonly AppPreferences _preferences;
    private Timer? _pollingTimer;
    private bool _isDisposed;
    private readonly SemaphoreSlim _lock = new(1, 1);

    public event Action<List<ProviderSnapshot>>? SnapshotsUpdated;
    private List<ProviderSnapshot> _lastGoodSnapshots = new();

    public UsageStore(IEnumerable<IUsageProvider> providers, UsageArchive archive, AppPreferences preferences)
    {
        _providers = providers;
        _archive = archive;
        _preferences = preferences;
    }

    public async Task StartPollingAsync()
    {
        _lastGoodSnapshots = await _archive.LoadAsync() ?? new List<ProviderSnapshot>();
        SnapshotsUpdated?.Invoke(_lastGoodSnapshots);

        _pollingTimer = new Timer(async _ => await PollAsync(), null, TimeSpan.Zero, TimeSpan.FromSeconds(60));
    }

    private async Task PollAsync()
    {
        await _lock.WaitAsync();
        try
        {
            var activeProviders = _providers.Where(p => !_preferences.DisconnectedProviders.Contains(p.Id)).ToList();
            var tasks = activeProviders.Select(p => p.FetchSnapshotAsync());
            var results = await Task.WhenAll(tasks);
            
            var newSnapshots = results.Where(r => r != null).ToList();
            _lastGoodSnapshots = newSnapshots;
            
            await _archive.SaveAsync(_lastGoodSnapshots);
            SnapshotsUpdated?.Invoke(_lastGoodSnapshots);
        }
        catch (Exception ex)
        {
            // Log exception
        }
        finally
        {
            _lock.Release();
        }
    }

    public void Dispose()
    {
        if (_isDisposed) return;
        _pollingTimer?.Dispose();
        _lock.Dispose();
        _isDisposed = true;
    }
}
