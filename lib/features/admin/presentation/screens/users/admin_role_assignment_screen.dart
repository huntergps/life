import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/app/theme/app_colors.dart';

// ── Data model ──

class _UserWithRoles {
  final String userId;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final List<_RoleEntry> roles;

  _UserWithRoles({
    required this.userId,
    required this.email,
    this.displayName,
    this.avatarUrl,
    required this.roles,
  });

  String get nameOrEmail =>
      (displayName?.isNotEmpty == true) ? displayName! : email;
}

class _RoleEntry {
  final String role;
  final DateTime? expiresAt;

  const _RoleEntry({required this.role, this.expiresAt});

  bool get isExpirable => role == 'beta_tester' || role == 'sponsored';
}

// ── Provider ──

final _usersWithRolesProvider =
    FutureProvider.autoDispose<List<_UserWithRoles>>((ref) async {
  final data = await Supabase.instance.client.rpc('get_all_users_with_roles');
  final rows = data as List;

  // Group by user_id
  final Map<String, _UserWithRoles> map = {};
  for (final row in rows) {
    final r = row as Map<String, dynamic>;
    final uid = r['user_id'] as String;
    if (!map.containsKey(uid)) {
      map[uid] = _UserWithRoles(
        userId: uid,
        email: (r['email'] as String?) ?? '',
        displayName: r['display_name'] as String?,
        avatarUrl: r['avatar_url'] as String?,
        roles: [],
      );
    }
    final role = r['role'] as String?;
    if (role != null) {
      map[uid]!.roles.add(_RoleEntry(
        role: role,
        expiresAt: r['expires_at'] != null
            ? DateTime.tryParse(r['expires_at'] as String)
            : null,
      ));
    }
  }
  final users = map.values.toList()
    ..sort((a, b) => a.email.compareTo(b.email));
  return users;
});

// ── Constants ──

const _assignableRoles = ['beta_tester', 'sponsored'];
const _staffRoles = {'admin', 'editor', 'curator'};

// ── Screen ──

class AdminRoleAssignmentScreen extends ConsumerWidget {
  const AdminRoleAssignmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(_usersWithRolesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEs = LocaleSettings.currentLocale == AppLocale.es;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEs ? 'Asignación de Roles' : 'Role Assignments'),
        backgroundColor: isDark ? AppColors.darkBackground : null,
      ),
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('$e', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(_usersWithRolesProvider),
                child: Text(isEs ? 'Reintentar' : 'Retry'),
              ),
            ],
          ),
        ),
        data: (users) {
          if (users.isEmpty) {
            return Center(
              child: Text(isEs ? 'No hay usuarios.' : 'No users found.'),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(_usersWithRolesProvider),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: users.length,
              separatorBuilder: (_, _) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final user = users[index];
                return _UserTile(
                  user: user,
                  isDark: isDark,
                  isEs: isEs,
                  onTap: () => _showRoleSheet(context, ref, user, isEs),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showRoleSheet(
    BuildContext context,
    WidgetRef ref,
    _UserWithRoles user,
    bool isEs,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      builder: (_) => _RoleAssignmentSheet(
        user: user,
        isEs: isEs,
        onChanged: () => ref.invalidate(_usersWithRolesProvider),
      ),
    );
  }
}

// ── User tile ──

class _UserTile extends StatelessWidget {
  final _UserWithRoles user;
  final bool isDark;
  final bool isEs;
  final VoidCallback onTap;

  const _UserTile({
    required this.user,
    required this.isDark,
    required this.isEs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd(isEs ? 'es' : 'en');
    return Card(
      color: isDark ? AppColors.darkCard : null,
      elevation: isDark ? 0 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDark
            ? const BorderSide(color: AppColors.darkBorder, width: 0.5)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: isDark
                        ? AppColors.primaryLight.withValues(alpha: 0.2)
                        : AppColors.primary.withValues(alpha: 0.1),
                    backgroundImage: user.avatarUrl != null
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                    child: user.avatarUrl == null
                        ? Icon(Icons.person,
                            size: 20,
                            color: isDark
                                ? AppColors.primaryLight
                                : AppColors.primary)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.nameOrEmail,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : null,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (user.displayName?.isNotEmpty == true)
                          Text(
                            user.email,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color:
                                          isDark ? Colors.white54 : Colors.grey,
                                    ),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right,
                      color: isDark ? Colors.white38 : Colors.grey),
                ],
              ),
              if (user.roles.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: user.roles.map((r) {
                    final isStaff = _staffRoles.contains(r.role);
                    final color = isStaff
                        ? AppColors.primary
                        : (r.role == 'sponsored'
                            ? AppColors.secondary
                            : Colors.blue);
                    final expiryLabel = r.expiresAt != null
                        ? ' ${isEs ? 'exp' : 'exp'}: ${dateFormat.format(r.expiresAt!)}'
                        : '';
                    return Chip(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      label: Text(
                        '${_roleLabel(r.role, isEs)}$expiryLabel',
                        style: TextStyle(fontSize: 11, color: color),
                      ),
                      side: BorderSide(color: color.withValues(alpha: 0.4)),
                      backgroundColor:
                          color.withValues(alpha: isDark ? 0.15 : 0.08),
                      padding: EdgeInsets.zero,
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Bottom sheet ──

class _RoleAssignmentSheet extends StatefulWidget {
  final _UserWithRoles user;
  final bool isEs;
  final VoidCallback onChanged;

  const _RoleAssignmentSheet({
    required this.user,
    required this.isEs,
    required this.onChanged,
  });

  @override
  State<_RoleAssignmentSheet> createState() => _RoleAssignmentSheetState();
}

class _RoleAssignmentSheetState extends State<_RoleAssignmentSheet> {
  String _selectedRole = 'beta_tester';
  int _durationMonths = 1; // default for beta_tester
  DateTime? _customDate;
  bool _isLoading = false;

  final _durations = [1, 3, 6, 12];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat.yMMMd(widget.isEs ? 'es' : 'en');
    final staffRoles =
        widget.user.roles.where((r) => _staffRoles.contains(r.role)).toList();
    final expirableRoles =
        widget.user.roles.where((r) => r.isExpirable).toList();

    // Already assigned expirable role names
    final assignedExpirable =
        expirableRoles.map((r) => r.role).toSet();

    // Roles still available to assign
    final availableRoles = _assignableRoles
        .where((r) => !assignedExpirable.contains(r))
        .toList();

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // User header
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: isDark
                      ? AppColors.primaryLight.withValues(alpha: 0.2)
                      : AppColors.primary.withValues(alpha: 0.1),
                  backgroundImage: widget.user.avatarUrl != null
                      ? NetworkImage(widget.user.avatarUrl!)
                      : null,
                  child: widget.user.avatarUrl == null
                      ? Icon(Icons.person,
                          color: isDark
                              ? AppColors.primaryLight
                              : AppColors.primary)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.user.nameOrEmail,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : null,
                                ),
                      ),
                      if (widget.user.displayName?.isNotEmpty == true)
                        Text(
                          widget.user.email,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isDark ? Colors.white54 : Colors.grey,
                                  ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Staff roles (read-only)
            if (staffRoles.isNotEmpty) ...[
              Text(
                widget.isEs ? 'Roles de staff' : 'Staff Roles',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: isDark ? Colors.white70 : Colors.grey[700],
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: staffRoles.map((r) {
                  return Chip(
                    label: Text(_roleLabel(r.role, widget.isEs)),
                    avatar:
                        const Icon(Icons.shield, size: 16, color: AppColors.primary),
                    side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.4)),
                    backgroundColor:
                        AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                  );
                }).toList(),
              ),
              const SizedBox(height: 6),
              Text(
                widget.isEs
                    ? 'Gestionados en la pantalla de Usuarios'
                    : 'Managed in the Users screen',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: isDark ? Colors.white38 : Colors.grey,
                    ),
              ),
              const SizedBox(height: 16),
            ],

            // Expirable roles (removable)
            Text(
              widget.isEs ? 'Roles activos' : 'Active Roles',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isDark ? Colors.white70 : Colors.grey[700],
                  ),
            ),
            const SizedBox(height: 8),
            if (expirableRoles.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  widget.isEs
                      ? 'Sin roles de beta/patrocinado'
                      : 'No beta/sponsored roles',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white38 : Colors.grey,
                      ),
                ),
              )
            else
              ...expirableRoles.map((r) {
                final color = r.role == 'sponsored'
                    ? AppColors.secondary
                    : Colors.blue;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        r.role == 'sponsored'
                            ? Icons.star
                            : Icons.bug_report,
                        size: 18,
                        color: color,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _roleLabel(r.role, widget.isEs),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : null,
                              ),
                            ),
                            if (r.expiresAt != null)
                              Text(
                                '${widget.isEs ? 'Expira' : 'Expires'}: ${dateFormat.format(r.expiresAt!)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color:
                                          isDark ? Colors.white54 : Colors.grey,
                                    ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        color: AppColors.error,
                        tooltip: widget.isEs ? 'Remover' : 'Remove',
                        onPressed: _isLoading
                            ? null
                            : () => _removeRole(r.role),
                      ),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 16),
            Divider(color: isDark ? AppColors.darkBorder : Colors.grey[300]),
            const SizedBox(height: 16),

            // Add role section
            Text(
              widget.isEs ? 'Agregar rol' : 'Add Role',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isDark ? Colors.white70 : Colors.grey[700],
                  ),
            ),
            const SizedBox(height: 12),

            if (availableRoles.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  widget.isEs
                      ? 'Todos los roles ya asignados'
                      : 'All roles already assigned',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.white54 : Colors.grey,
                      ),
                ),
              )
            else ...[
              // Role dropdown
              DropdownButtonFormField<String>(
                initialValue: availableRoles.contains(_selectedRole)
                    ? _selectedRole
                    : availableRoles.first,
                decoration: InputDecoration(
                  labelText: widget.isEs ? 'Rol' : 'Role',
                  border: const OutlineInputBorder(),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: availableRoles.map((r) {
                  return DropdownMenuItem(
                    value: r,
                    child: Text(_roleLabel(r, widget.isEs)),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    _selectedRole = v;
                    // Default durations
                    _durationMonths = v == 'sponsored' ? 3 : 1;
                    _customDate = null;
                  });
                },
              ),
              const SizedBox(height: 14),

              // Duration presets
              Text(
                widget.isEs ? 'Duración' : 'Duration',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isDark ? Colors.white54 : Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._durations.map((m) {
                    final isSelected =
                        _customDate == null && _durationMonths == m;
                    final label = m == 12
                        ? (widget.isEs ? '1 año' : '1 year')
                        : (widget.isEs ? '$m ${m == 1 ? 'mes' : 'meses'}' : '$m ${m == 1 ? 'month' : 'months'}');
                    return ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          _durationMonths = m;
                          _customDate = null;
                        });
                      },
                    );
                  }),
                  ActionChip(
                    label: Text(
                      _customDate != null
                          ? dateFormat.format(_customDate!)
                          : (widget.isEs ? 'Personalizado...' : 'Custom...'),
                    ),
                    avatar: const Icon(Icons.calendar_today, size: 16),
                    side: _customDate != null
                        ? const BorderSide(color: AppColors.primary)
                        : null,
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate:
                            DateTime.now().add(const Duration(days: 30)),
                        firstDate:
                            DateTime.now().add(const Duration(days: 1)),
                        lastDate:
                            DateTime.now().add(const Duration(days: 365 * 3)),
                      );
                      if (picked != null) {
                        setState(() => _customDate = picked);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Assign button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isLoading ? null : _assignRole,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.add),
                  label: Text(
                      widget.isEs ? 'Asignar Rol' : 'Assign Role'),
                ),
              ),
            ],
            const SizedBox(height: 16),

            // ── Certificate management ──
            const Divider(),
            const SizedBox(height: 8),
            Text(
              widget.isEs ? 'Certificado' : 'Certificate',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _revokeCertificate,
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                label: Text(
                  widget.isEs
                      ? 'Revocar certificado (permite re-emitir)'
                      : 'Revoke certificate (allows re-issue)',
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _revokeCertificate() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(widget.isEs ? 'Revocar certificado' : 'Revoke Certificate'),
        content: Text(widget.isEs
            ? 'El usuario podra volver a emitir su certificado. ¿Continuar?'
            : 'The user will be able to re-issue their certificate. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(widget.isEs ? 'Cancelar' : 'Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(widget.isEs ? 'Revocar' : 'Revoke'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.rpc('revoke_checklist_certificate', params: {
        'target_user_id': widget.user.userId,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.isEs ? 'Certificado revocado' : 'Certificate revoked')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  DateTime _computeExpiryDate() {
    if (_customDate != null) return _customDate!;
    final now = DateTime.now();
    return DateTime(now.year, now.month + _durationMonths, now.day);
  }

  Future<void> _assignRole() async {
    final role = _selectedRole;
    final expiresAt = _computeExpiryDate();

    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.rpc('grant_role_with_expiry', params: {
        'target_user_id': widget.user.userId,
        'target_role': role,
        'target_expires_at': expiresAt.toUtc().toIso8601String(),
      });
      widget.onChanged();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.isEs ? 'Error' : 'Error'}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _removeRole(String role) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(widget.isEs ? 'Confirmar' : 'Confirm'),
        content: Text(
          widget.isEs
              ? '¿Remover el rol "${_roleLabel(role, true)}" de ${widget.user.nameOrEmail}?'
              : 'Remove "${_roleLabel(role, false)}" role from ${widget.user.nameOrEmail}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(widget.isEs ? 'Cancelar' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(widget.isEs ? 'Remover' : 'Remove'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.rpc('revoke_role', params: {
        'target_user_id': widget.user.userId,
        'target_role': role,
      });
      widget.onChanged();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.isEs ? 'Error' : 'Error'}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

// ── Helpers ──

String _roleLabel(String role, bool isEs) {
  switch (role) {
    case 'admin':
      return 'Admin';
    case 'editor':
      return isEs ? 'Editor' : 'Editor';
    case 'curator':
      return isEs ? 'Curador' : 'Curator';
    case 'beta_tester':
      return 'Beta Tester';
    case 'sponsored':
      return isEs ? 'Patrocinado' : 'Sponsored';
    default:
      return role;
  }
}
