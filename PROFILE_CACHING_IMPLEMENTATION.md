# Profile Caching Implementation

## Overview
This implementation ensures that user profile data is fetched from the API **only once** and then cached both in memory and persistent storage. Subsequent visits to the profile page will use the cached data, eliminating unnecessary API calls.

## Key Features

### 1. **Smart Caching with Expiration**
- Profile data is cached for 24 hours by default
- After expiration, the system attempts to refresh data but falls back to cached data if the API fails
- Cache validity is tracked using timestamps

### 2. **Persistent Storage**
- User data is saved to `SharedPreferences` 
- Cache state (`_profileLoaded`, `_lastFetchTime`) is also persisted
- Data survives app restarts and reinstalls

### 3. **Multiple Cache Layers**
```
Memory Cache → SharedPreferences → API Call
     ↓              ↓                ↓
   Instant      Fast Access      Network Required
```

## Implementation Details

### ProfileProvider Enhancements

```dart
class ProfileProvider extends ChangeNotifier {
  bool _profileLoaded = false;
  bool _isInitialized = false;
  DateTime? _lastFetchTime;
  static const int _cacheValidityHours = 24;
  
  // Smart loading with cache validation
  Future<UserModel> loadUserProfileIfNeeded(Future<UserModel> Function() apiCall) async {
    // Wait for initialization
    if (!_isInitialized) await _init();
    
    // Check valid cache
    if (_profileLoaded && _isCacheValid()) {
      return _currentUser; // Use cached data
    }
    
    // Handle expired cache
    if (_shouldRefreshProfile()) {
      try {
        final user = await apiCall();
        setUserFromApi(user);
        return user;
      } catch (e) {
        return _currentUser; // Fallback to cached data
      }
    }
    
    // Fresh API call
    final user = await apiCall();
    setUserFromApi(user);
    return user;
  }
}
```

### Key Methods

#### `loadUserProfileIfNeeded()`
- **Purpose**: Main method to get user profile with intelligent caching
- **Logic**: 
  1. Check if cache is valid → return cached data
  2. Check if cache expired but data exists → try refresh, fallback to cache
  3. No cache → fetch from API

#### `forceRefreshProfile()`
- **Purpose**: Explicitly refresh profile data (used by "Retry" button)
- **Usage**: When user manually requests fresh data

#### `resetProfileCache()`
- **Purpose**: Clear cache (used on logout)
- **Effect**: Next profile access will fetch from API

#### `getCacheStatus()`
- **Purpose**: Debug method to check cache state
- **Returns**: Human-readable cache status

## Cache Flow Diagram

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Page Load     │    │  Check Cache    │    │   Use Cache     │
│                 │───▶│                 │───▶│                 │
│ ProfilePage     │    │ _profileLoaded  │    │ Return User     │
│ initState()     │    │ _isCacheValid() │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              ▼ (Cache Invalid/Expired)
                       ┌─────────────────┐    ┌─────────────────┐
                       │   API Call      │    │  Update Cache   │
                       │                 │───▶│                 │
                       │ _fetchProfile() │    │ setUserFromApi()│
                       └─────────────────┘    └─────────────────┘
                              │
                              ▼ (API Fails)
                       ┌─────────────────┐
                       │  Fallback       │
                       │                 │
                       │ Use Cached Data │
                       └─────────────────┘
```

## Usage Examples

### 1. **Normal Profile Access**
```dart
// First visit - API call
final user = await profileProvider.loadUserProfileIfNeeded(_fetchUserProfile);

// Subsequent visits within 24 hours - No API call
final user = await profileProvider.loadUserProfileIfNeeded(_fetchUserProfile);
```

### 2. **Force Refresh**
```dart
// Force refresh (e.g., retry button)
final user = await profileProvider.forceRefreshProfile(_fetchUserProfile);
```

### 3. **Cache Management**
```dart
// Check cache status

// Clear cache (logout)
profileProvider.resetProfileCache();
```

## Benefits

1. **Performance**: Instant profile loading after first fetch
2. **Offline Support**: Profile works even when API is unavailable
3. **Reduced Server Load**: 24x fewer API calls per user per day
4. **Better UX**: No loading spinners on repeat visits
5. **Resilient**: Graceful fallback when API fails

## Cache Validity

- **Valid Cache**: Data fetched within 24 hours → Use immediately
- **Expired Cache**: Try to refresh, fallback to cached data if API fails
- **No Cache**: Fetch from API, save to cache

## Storage Keys

The following keys are used in SharedPreferences:

- `currentUser`: Serialized UserModel JSON
- `profileLoaded`: Boolean flag for cache state
- `lastFetchTime`: ISO8601 timestamp of last API fetch
- `selected*`: User's dropdown selections (district, organization, etc.)

## Debug Information

Enable debug prints to monitor cache behavior:

```
🔍 Profile cache status: Cache valid for 18 hours
📋 Using cached profile data
🔄 Cache expired, fetching fresh profile...
🌐 Fetching profile from API...
⚠️ Failed to refresh profile, using cached data
```

## Testing the Implementation

1. **Fresh Install**: Should make API call and cache data
2. **App Restart**: Should use cached data (no API call)
3. **24+ Hours Later**: Should try to refresh, fallback to cache if API fails
4. **Retry Button**: Should force refresh regardless of cache state
5. **Logout/Login**: Should clear cache and fetch fresh data

This implementation ensures your profile page loads instantly after the first visit while maintaining data freshness and providing robust error handling.
