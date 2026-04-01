# Access Control

This document describes how roles, route guards, and feature gating work in the
Galapagos Wildlife app.

---

## 1. Roles

| Role | Purpose |
|---|---|
| `admin` | Full access. Inherits all lower-tier permissions. |
| `editor` | Can propose species edits (editorial workflow). |
| `curator` | Reviews editor proposals and validates AI feedback. |
| `beta_tester` | Unlocks beta-only features (map, photo-id, field camera). |

Roles are stored in the `admin_users` table with a UNIQUE constraint on
`(user_id, role)`. A single user can hold multiple roles simultaneously.

The `admin` role implicitly grants all other permissions -- every role-check
provider treats `admin` as a superset.

---

## 2. How roles are fetched

### Server-side RPC

```sql
-- Returns text[] of the authenticated user's roles
SELECT get_user_roles();
```

The Flutter client calls this via `Supabase.instance.client.rpc('get_user_roles')`
inside a `FutureProvider` (`_rolesCheckProvider`) defined in:

```
lib/features/admin/providers/admin_auth_provider.dart
```

### Caching (SharedPreferences)

After each successful fetch the role set is persisted:

| Key | Type | Description |
|---|---|---|
| `user_roles` | `String` | Comma-joined role names (e.g. `"admin,editor"`) |
| `roles_cache_ts` | `int` | Epoch millis of last fetch |
| `is_admin` | `bool` | Legacy sync flag for router guard |
| `is_curator` | `bool` | Legacy sync flag (includes admin) |
| `is_editor` | `bool` | Legacy sync flag (includes admin) |
| `is_staff` | `bool` | True if any role exists |
| `is_beta_tester` | `bool` | Legacy sync flag (includes admin) |

The `userRolesProvider` merges the async server result with the cached value so
the UI never flickers on cold start -- if the server hasn't responded yet, the
cached roles are used.

---

## 3. Convenience providers

All defined in `lib/features/admin/providers/admin_auth_provider.dart`:

| Provider | Type | Logic |
|---|---|---|
| `userRolesProvider` | `Provider<AsyncValue<Set<String>>>` | Full role set |
| `isAdminProvider` | `Provider<AsyncValue<bool>>` | `roles.contains('admin')` |
| `isEditorProvider` | `Provider<AsyncValue<bool>>` | `editor OR admin` |
| `isCuratorProvider` | `Provider<AsyncValue<bool>>` | `curator OR admin` |
| `isStaffProvider` | `Provider<AsyncValue<bool>>` | `roles.isNotEmpty` |
| `isBetaTesterProvider` | `Provider<AsyncValue<bool>>` | `beta_tester OR admin` |

Call `invalidateRoles(ref)` after granting/revoking a role to force a re-fetch
from the server and clear the cache.

---

## 4. Route guards (app_router.dart)

Guards are implemented in the `redirect` callback of `GoRouter` at
`lib/app/router/app_router.dart`.

### Admin route group (`/admin/**`)

```
/admin              -> requires admin
/admin/curator      -> requires admin OR curator
/admin/my-proposals -> requires admin OR editor
/admin/*            -> requires admin (all other sub-routes)
```

The guard reads the synchronous `SharedPreferences` booleans (`is_admin`,
`is_curator`, `is_editor`) rather than the async provider, so it works on cold
start before providers have initialized. Unauthenticated users are redirected
to `/`.

### Beta feature gating

The routes `/map`, `/photo-id`, and `/field-camera` are gated behind the
`is_beta_tester` SharedPreferences flag. Non-beta users are redirected to `/`.

The Settings screen also conditionally shows beta feature toggles using
`isBetaTesterProvider`.

---

## 5. Admin route definitions

All admin routes are defined in `lib/app/router/routes/admin_routes.dart` and
mounted under the `/admin` prefix within the shell route:

| Path | Screen | Required role |
|---|---|---|
| `/admin` | `AdminDashboardScreen` | admin |
| `/admin/species` | `AdminSpeciesListScreen` | admin |
| `/admin/species/new` | `AdminSpeciesFormScreen` | admin |
| `/admin/species/:id/edit` | `AdminSpeciesFormScreen` | admin |
| `/admin/species/:id/images` | `AdminSpeciesImagesScreen` | admin |
| `/admin/categories` | `AdminCategoryListScreen` | admin |
| `/admin/islands` | `AdminIslandListScreen` | admin |
| `/admin/visit-sites` | `AdminVisitSiteListScreen` | admin |
| `/admin/species-sites` | `AdminSpeciesSitesScreen` | admin |
| `/admin/taxonomy` | `AdminTaxonomyScreen` | admin |
| `/admin/site-catalogs` | `AdminSiteCatalogsScreen` | admin |
| `/admin/users` | `AdminUsersScreen` | admin |
| `/admin/proposals` | `AdminProposalsScreen` | admin |
| `/admin/ml-training` | `AdminMlTrainingScreen` | admin |
| `/admin/curator` | `CuratorScreen` | admin or curator |
| `/admin/my-proposals` | `MyProposalsScreen` | admin or editor |

---

## 6. Granting and revoking roles via Supabase

### RPCs (called from Flutter or Supabase dashboard)

| RPC | Parameters | Description |
|---|---|---|
| `grant_admin(target_user_id)` | UUID | Legacy -- grants admin role |
| `revoke_admin(target_user_id)` | UUID | Legacy -- revokes admin role |
| `grant_role(target_user_id, target_role)` | UUID, text | Grants any role |
| `revoke_role(target_user_id, target_role)` | UUID, text | Revokes any role |
| `get_user_roles()` | (none) | Returns current user's roles as text[] |
| `get_all_users()` | (none) | Admin-only: all users with roles |

### Flutter helpers

Located in `lib/features/admin/providers/admin_users_provider.dart`:

- `adminGrantAdmin(userId)` / `adminRevokeAdmin(userId)` -- legacy
- `adminGrantRole(userId, role)` / `adminRevokeRole(userId, role)` -- preferred
- `adminInviteUser(email)` -- sends invitation via Edge Function

### Manual via Supabase SQL Editor

```sql
-- Grant a role
INSERT INTO admin_users (user_id, role)
VALUES ('<uuid>', 'editor')
ON CONFLICT DO NOTHING;

-- Revoke a role
DELETE FROM admin_users
WHERE user_id = '<uuid>' AND role = 'editor';

-- List all roles for a user
SELECT role FROM admin_users WHERE user_id = '<uuid>';
```

---

## 7. Cross-boundary imports (known)

The role-check providers in `lib/features/admin/providers/admin_auth_provider.dart`
are intentionally imported by public features that need role-aware UI:

| Importing file | Reason |
|---|---|
| `lib/features/settings/presentation/screens/settings_screen.dart` | Shows admin/editor/curator panel links based on roles |
| `lib/features/species/detail/species_detail_screen.dart` | Shows edit button for editors |
| `lib/features/map/presentation/widgets/field_edit_toolbar.dart` | Shows field editing FAB for admins |
| `lib/app/router/navigation/scaffold_with_nav.dart` | Adapts navigation rail for admin routes |

Additionally, `image_processing_service.dart` (under `admin/services/`) is
imported by:

| Importing file | Reason |
|---|---|
| `lib/features/sightings/presentation/screens/add_sighting_screen.dart` | Image crop/resize for sighting photos |
| `lib/features/profile/providers/profile_provider.dart` | Avatar image processing |

The `image_processing_service.dart` is a general-purpose utility that happens to
live under admin. It could be moved to `lib/core/services/` in a future phase,
but it has no admin-specific logic -- it only handles image cropping and resizing.

---

## 8. Database-level security

The `admin_users` table has RLS enabled. The `is_admin()`, `is_editor()`,
`is_curator()`, and `is_staff()` helper functions are `SECURITY DEFINER` and
used in RLS policies across the schema to restrict write operations on protected
tables (species, species_images, etc.) to authorized roles.

The `species_change_proposals` table enforces the editorial workflow:
editor -> curator -> admin approval chain.
