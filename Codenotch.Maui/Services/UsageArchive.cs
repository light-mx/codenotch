using System;
using System.Collections.Generic;
using System.IO;
using System.Text.Json;
using System.Threading.Tasks;
using Codenotch.Models;

namespace Codenotch.Services;

public class UsageArchive
{
    private readonly string _filePath;
    private readonly JsonSerializerOptions _jsonOptions = new() { PropertyNameCaseInsensitive = true, WriteIndented = true };

    public UsageArchive(string storageDirectory)
    {
        _filePath = Path.Combine(storageDirectory, "usage_archive.json");
    }

    public async Task SaveAsync(List<ProviderSnapshot> snapshots)
    {
        try
        {
            var json = JsonSerializer.Serialize(snapshots, _jsonOptions);
            await File.WriteAllTextAsync(_filePath, json);
        }
        catch (Exception)
        {
            // Log error
        }
    }

    public async Task<List<ProviderSnapshot>?> LoadAsync()
    {
        if (!File.Exists(_filePath)) return null;

        try
        {
            var json = await File.ReadAllTextAsync(_filePath);
            return JsonSerializer.Deserialize<List<ProviderSnapshot>>(json, _jsonOptions);
        }
        catch (Exception)
        {
            // Log error
            return null;
        }
    }
}
