import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:galapagos_wildlife/app/theme/app_colors.dart';
import 'package:galapagos_wildlife/features/admin/providers/admin_users_provider.dart';

class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUsersProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios'),
        backgroundColor: isDark ? AppColors.darkBackground : null,
        actions: [
          TextButton.icon(
            onPressed: () => _showInviteDialog(context, ref),
            icon: const Icon(Icons.person_add_outlined),
            label: const Text('Invitar usuario'),
          ),
        ],
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
                onPressed: () => ref.invalidate(adminUsersProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (users) {
          if (users.isEmpty) {
            return const Center(child: Text('No hay usuarios registrados.'));
          }

          final isWide = MediaQuery.of(context).size.width >= 600;

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(adminUsersProvider),
            child: isWide
                ? _DesktopTable(users: users, isDark: isDark, ref: ref)
                : _MobileList(users: users, isDark: isDark, ref: ref),
          );
        },
      ),
    );
  }

  Future<void> _showInviteDialog(BuildContext context, WidgetRef ref) async {
    final emailCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Invitar usuario'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
              hintText: 'usuario@ejemplo.com',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Ingresa un correo';
              if (!v.contains('@')) return 'Correo inválido';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);
              await _doInvite(context, ref, emailCtrl.text.trim());
            },
            child: const Text('Enviar invitación'),
          ),
        ],
      ),
    );
    emailCtrl.dispose();
  }

  Future<void> _doInvite(
      BuildContext context, WidgetRef ref, String email) async {
    try {
      await adminInviteUser(email);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invitación enviada a $email'),
            backgroundColor: Colors.green.shade700,
          ),
        );
        ref.invalidate(adminUsersProvider);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Mobile — card list
// ---------------------------------------------------------------------------

class _MobileList extends StatelessWidget {
  const _MobileList(
      {required this.users, required this.isDark, required this.ref});

  final List<AdminUserRecord> users;
  final bool isDark;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) =>
          _UserCard(user: users[i], isDark: isDark, ref: ref),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard(
      {required this.user, required this.isDark, required this.ref});

  final AdminUserRecord user;
  final bool isDark;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final currentUid = Supabase.instance.client.auth.currentUser?.id;
    final isSelf = user.id == currentUid;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : Colors.grey.shade200,
        ),
        boxShadow: isDark
            ? null
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: avatar + name + email + self badge
          Row(
            children: [
              _Avatar(url: user.avatarUrl, radius: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.nameOrEmail,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isSelf) ...[
                          const SizedBox(width: 8),
                          _Badge(label: 'Tú', color: AppColors.accentOrange),
                        ],
                      ],
                    ),
                    if (user.displayName != null)
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              // Admin toggle (not for self)
              if (!isSelf)
                _AdminToggle(user: user, isDark: isDark, ref: ref),
            ],
          ),
          const SizedBox(height: 10),
          // Role chips
          Wrap(
            spacing: 6,
            children: [
              if (user.isAdmin)
                _Badge(label: 'Admin', color: AppColors.primary),
              if (user.isEditor)
                _Badge(label: 'Editor', color: Colors.indigo),
              if (user.isCurator)
                _Badge(label: 'Curador', color: Colors.teal),
              if (user.sightingsCount > 0)
                _Badge(
                  label: '${user.sightingsCount} avistamientos',
                  color: Colors.grey,
                ),
            ],
          ),
          const SizedBox(height: 10),
          // Bottom row: timestamp + edit button
          Row(
            children: [
              Icon(Icons.access_time,
                  size: 14,
                  color: isDark ? Colors.white38 : Colors.black38),
              const SizedBox(width: 4),
              Text(
                _formatDate(user.lastSignInAt ?? user.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () => _showEditSheet(context, user, isDark, ref),
                icon: const Icon(Icons.manage_accounts_outlined, size: 16),
                label: const Text('Editar'),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Desktop — table
// ---------------------------------------------------------------------------

class _DesktopTable extends StatelessWidget {
  const _DesktopTable(
      {required this.users, required this.isDark, required this.ref});

  final List<AdminUserRecord> users;
  final bool isDark;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              // Header row
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface
                      : Colors.grey.shade100,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    const Expanded(
                        flex: 3,
                        child: Text('Usuario',
                            style:
                                TextStyle(fontWeight: FontWeight.w600))),
                    const Expanded(
                        flex: 2,
                        child: Text('Rol',
                            style:
                                TextStyle(fontWeight: FontWeight.w600))),
                    const Expanded(
                        flex: 2,
                        child: Text('Último acceso',
                            style:
                                TextStyle(fontWeight: FontWeight.w600))),
                    SizedBox(
                        width: 120,
                        child: Text('Estado',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600))),
                  ],
                ),
              ),
              // Rows
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : Colors.grey.shade200,
                  ),
                  borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(12)),
                ),
                child: Column(
                  children: users
                      .map((u) => _TableRow(
                          user: u, allUsers: users, isDark: isDark, ref: ref))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow(
      {required this.user, required this.allUsers, required this.isDark, required this.ref});

  final AdminUserRecord user;
  final List<AdminUserRecord> allUsers;
  final bool isDark;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final currentUid = Supabase.instance.client.auth.currentUser?.id;
    final isSelf = user.id == currentUid;


    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // Usuario column
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    _Avatar(url: user.avatarUrl, radius: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  user.nameOrEmail,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isSelf) ...[
                                const SizedBox(width: 6),
                                _Badge(
                                    label: 'Tú',
                                    color: AppColors.accentOrange),
                              ],
                            ],
                          ),
                          if (user.displayName != null)
                            Text(
                              user.email,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.white54
                                    : Colors.black45,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Rol column
              Expanded(
                flex: 2,
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    if (user.isAdmin)
                      _Badge(label: 'Admin', color: AppColors.primary),
                    if (user.isEditor)
                      _Badge(label: 'Editor', color: Colors.indigo),
                    if (user.isCurator)
                      _Badge(label: 'Curador', color: Colors.teal),
                    if (user.sightingsCount > 0)
                      _Badge(
                        label: '${user.sightingsCount}',
                        color: Colors.grey,
                        icon: Icons.visibility_outlined,
                      ),
                  ],
                ),
              ),
              // Último acceso column
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 13,
                        color: isDark
                            ? Colors.white38
                            : Colors.black38),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(
                          user.lastSignInAt ?? user.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.white54
                            : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              // Estado column
              SizedBox(
                width: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!isSelf)
                      _AdminToggle(user: user, isDark: isDark, ref: ref),
                    if (!isSelf) const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(
                          Icons.manage_accounts_outlined,
                          size: 18),
                      tooltip: 'Editar',
                      onPressed: () =>
                          _showEditSheet(context, user, isDark, ref),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (user != allUsers.last)
          Divider(
              height: 1,
              color: isDark
                  ? AppColors.darkBorder
                  : Colors.grey.shade100),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.radius});
  final String? url;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      backgroundImage:
          url != null && url!.isNotEmpty ? NetworkImage(url!) : null,
      child: url == null || url!.isEmpty
          ? Icon(Icons.person,
              size: radius * 1.1, color: AppColors.primary)
          : null,
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color, this.icon});
  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 3),
          ],
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }
}

class _AdminToggle extends StatefulWidget {
  const _AdminToggle(
      {required this.user, required this.isDark, required this.ref});
  final AdminUserRecord user;
  final bool isDark;
  final WidgetRef ref;

  @override
  State<_AdminToggle> createState() => _AdminToggleState();
}

class _AdminToggleState extends State<_AdminToggle> {
  bool _loading = false;

  Future<void> _toggle() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(widget.user.isAdmin
            ? 'Revocar acceso de administrador'
            : 'Otorgar acceso de administrador'),
        content: Text(widget.user.isAdmin
            ? '${widget.user.nameOrEmail} perderá acceso al panel de administración.'
            : '${widget.user.nameOrEmail} podrá gestionar toda la información del app.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Confirmar')),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    setState(() => _loading = true);
    try {
      if (widget.user.isAdmin) {
        await adminRevokeAdmin(widget.user.id);
      } else {
        await adminGrantAdmin(widget.user.id);
      }
      widget.ref.invalidate(adminUsersProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
          width: 36, height: 20, child: CircularProgressIndicator(strokeWidth: 2));
    }
    return Switch(
      value: widget.user.isAdmin,
      onChanged: (_) => _toggle(),
      activeThumbColor: AppColors.accentOrange,
    );
  }
}

// ---------------------------------------------------------------------------
// Edit / detail bottom sheet
// ---------------------------------------------------------------------------

void _showEditSheet(BuildContext context, AdminUserRecord user, bool isDark,
    WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.85,
    ),
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => SingleChildScrollView(
      child: _UserDetailSheet(user: user, isDark: isDark, ref: ref),
    ),
  );
}

class _UserDetailSheet extends StatelessWidget {
  const _UserDetailSheet(
      {required this.user, required this.isDark, required this.ref});
  final AdminUserRecord user;
  final bool isDark;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final currentUid = Supabase.instance.client.auth.currentUser?.id;
    final isSelf = user.id == currentUid;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // User header
          Row(
            children: [
              _Avatar(url: user.avatarUrl, radius: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.nameOrEmail,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (isSelf) ...[
                          const SizedBox(width: 8),
                          _Badge(
                              label: 'Tú',
                              color: AppColors.accentOrange),
                        ],
                      ],
                    ),
                    if (user.displayName != null)
                      Text(user.email,
                          style: TextStyle(
                              color: isDark
                                  ? Colors.white60
                                  : Colors.black54)),
                    if (user.country != null)
                      Text(user.country!,
                          style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.white54
                                  : Colors.black45)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Stats row
          Row(
            children: [
              _StatItem(
                icon: Icons.visibility_outlined,
                label: 'Avistamientos',
                value: '${user.sightingsCount}',
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              _StatItem(
                icon: Icons.calendar_today_outlined,
                label: 'Miembro desde',
                value: _formatDate(user.createdAt),
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              _StatItem(
                icon: Icons.access_time,
                label: 'Último acceso',
                value: _formatDate(user.lastSignInAt),
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Role management
          ...[
            const Divider(),
            const SizedBox(height: 8),
            const Text('Roles',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            if (!isSelf)
              _RoleRow(
                icon: Icons.admin_panel_settings_outlined,
                label: 'Administrador',
                description: 'Gestiona todo el contenido y aprueba propuestas',
                hasRole: user.isAdmin,
                role: 'admin',
                userId: user.id,
                isSelf: isSelf,
                isDark: isDark,
                ref: ref,
              ),
            if (!isSelf) const SizedBox(height: 8),
            _RoleRow(
              icon: Icons.edit_note_outlined,
              label: 'Editor',
              description: 'Propone cambios en la info de especies',
              hasRole: user.isEditor,
              role: 'editor',
              userId: user.id,
              isSelf: false,
              isDark: isDark,
              ref: ref,
            ),
            const SizedBox(height: 8),
            _RoleRow(
              icon: Icons.science_outlined,
              label: 'Curador',
              description: 'Revisa propuestas y valida correcciones de IA',
              hasRole: user.isCurator,
              role: 'curator',
              userId: user.id,
              isSelf: false,
              isDark: isDark,
              ref: ref,
            ),

            // ── Sponsored / Beta Tester (with expiry) ──
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text('Acceso Premium',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 4),
            Text('Roles con fecha de caducidad',
                style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.grey)),
            const SizedBox(height: 12),
            _ExpiringRoleButton(
              label: 'Sponsored',
              description: 'Acceso premium gratuito (estudiantes, investigadores)',
              icon: Icons.school_outlined,
              role: 'sponsored',
              userId: user.id,
              isDark: isDark,
              ref: ref,
            ),
            const SizedBox(height: 8),
            _ExpiringRoleButton(
              label: 'Beta Tester',
              description: 'Acceso a funciones experimentales',
              icon: Icons.bug_report_outlined,
              role: 'beta_tester',
              userId: user.id,
              isDark: isDark,
              ref: ref,
            ),

            // ── User Type Badge ──
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            _UserTypeSection(userId: user.id, isDark: isDark),

            // ── Certificate ──
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text('Certificado',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Revocar certificado'),
                      content: const Text('El usuario podra volver a emitir su certificado. ¿Continuar?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                        TextButton(
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Revocar'),
                        ),
                      ],
                    ),
                  );
                  if (confirm != true) return;
                  try {
                    await Supabase.instance.client.rpc('revoke_checklist_certificate', params: {
                      'target_user_id': user.id,
                    });
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Certificado revocado')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                label: const Text('Revocar certificado', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Expiring role button with duration picker ──

class _ExpiringRoleButton extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final String role;
  final String userId;
  final bool isDark;
  final WidgetRef ref;

  const _ExpiringRoleButton({
    required this.label,
    required this.description,
    required this.icon,
    required this.role,
    required this.userId,
    required this.isDark,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: isDark ? Colors.white70 : Colors.grey.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(description, style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _DurationChip(label: '1 mes', months: 1, role: role, userId: userId, ref: ref),
              _DurationChip(label: '3 meses', months: 3, role: role, userId: userId, ref: ref),
              _DurationChip(label: '6 meses', months: 6, role: role, userId: userId, ref: ref),
              _DurationChip(label: '1 año', months: 12, role: role, userId: userId, ref: ref),
              ActionChip(
                avatar: const Icon(Icons.calendar_today, size: 14),
                label: const Text('Fecha...', style: TextStyle(fontSize: 12)),
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 90)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  );
                  if (date == null) return;
                  await _assignWithExpiry(context, role, userId, date, ref);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Future<void> _assignWithExpiry(
    BuildContext context, String role, String userId, DateTime expiresAt, WidgetRef ref,
  ) async {
    try {
      await Supabase.instance.client.rpc('grant_role_with_expiry', params: {
        'target_user_id': userId,
        'target_role': role,
        'target_expires_at': expiresAt.toIso8601String(),
      });
      ref.invalidate(adminUsersProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$role asignado hasta ${DateFormat.yMMMd('es').format(expiresAt)}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}

class _DurationChip extends StatelessWidget {
  final String label;
  final int months;
  final String role;
  final String userId;
  final WidgetRef ref;

  const _DurationChip({
    required this.label,
    required this.months,
    required this.role,
    required this.userId,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: () {
        final expiresAt = DateTime.now().add(Duration(days: months * 30));
        _ExpiringRoleButton._assignWithExpiry(context, role, userId, expiresAt, ref);
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem(
      {required this.icon,
      required this.label,
      required this.value,
      required this.isDark});
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isDark ? AppColors.darkBorder : Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15)),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.white38 : Colors.black38)),
          ],
        ),
      ),
    );
  }
}

// ── Role row for the edit sheet ───────────────────────────────────────────────

class _RoleRow extends StatefulWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool hasRole;
  final String role;
  final String userId;
  final bool isSelf;
  final bool isDark;
  final WidgetRef ref;

  const _RoleRow({
    required this.icon,
    required this.label,
    required this.description,
    required this.hasRole,
    required this.role,
    required this.userId,
    required this.isSelf,
    required this.isDark,
    required this.ref,
  });

  @override
  State<_RoleRow> createState() => _RoleRowState();
}

class _RoleRowState extends State<_RoleRow> {
  bool _loading = false;

  Future<void> _toggle() async {
    setState(() => _loading = true);
    try {
      if (widget.hasRole) {
        await adminRevokeRole(widget.userId, widget.role);
      } else {
        await adminGrantRole(widget.userId, widget.role);
      }
      widget.ref.invalidate(adminUsersProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(widget.icon,
            color: widget.hasRole ? AppColors.primary : Colors.grey, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.label,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(widget.description,
                  style: TextStyle(
                      fontSize: 12,
                      color: widget.isDark ? Colors.white54 : Colors.black54)),
            ],
          ),
        ),
        if (_loading)
          const SizedBox(
              width: 36,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2))
        else
          Switch(
            value: widget.hasRole,
            onChanged: widget.isSelf ? null : (_) => _toggle(),
            activeThumbColor: AppColors.primary,
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Utilities
// ---------------------------------------------------------------------------

String _formatDate(DateTime? dt) {
  if (dt == null) return '—';
  return DateFormat('dd/MM/yyyy HH:mm').format(dt.toLocal());
}

// ---------------------------------------------------------------------------
// User Type Section (stateful — dropdown + optional text field)
// ---------------------------------------------------------------------------

class _UserTypeSection extends StatefulWidget {
  const _UserTypeSection({required this.userId, required this.isDark});
  final String userId;
  final bool isDark;

  @override
  State<_UserTypeSection> createState() => _UserTypeSectionState();
}

class _UserTypeSectionState extends State<_UserTypeSection> {
  String? _selectedType;
  final _affiliationCtrl = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  static const _types = ['tourist', 'researcher', 'guide', 'ranger', 'student'];
  static const _labels = {
    'tourist': 'Turista',
    'researcher': 'Investigador/a',
    'guide': 'Guia naturalista',
    'ranger': 'Guardaparque',
    'student': 'Estudiante',
  };

  @override
  void initState() {
    super.initState();
    _loadCurrentType();
  }

  Future<void> _loadCurrentType() async {
    try {
      final row = await Supabase.instance.client
          .from('profiles')
          .select('user_type, affiliation')
          .eq('id', widget.userId)
          .maybeSingle();
      if (mounted) {
        setState(() {
          _selectedType = (row?['user_type'] as String?) ?? 'tourist';
          _affiliationCtrl.text = (row?['affiliation'] as String?) ?? '';
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await Supabase.instance.client.from('profiles').update({
        'user_type': _selectedType,
        'affiliation': (_selectedType == 'researcher' || _selectedType == 'student')
            ? _affiliationCtrl.text.trim().isEmpty
                ? null
                : _affiliationCtrl.text.trim()
            : null,
      }).eq('id', widget.userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tipo de usuario actualizado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _affiliationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tipo de usuario',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedType,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: _types
              .map((t) => DropdownMenuItem(value: t, child: Text(_labels[t] ?? t)))
              .toList(),
          onChanged: (v) => setState(() => _selectedType = v),
        ),
        if (_selectedType == 'researcher' || _selectedType == 'student') ...[
          const SizedBox(height: 12),
          TextField(
            controller: _affiliationCtrl,
            decoration: const InputDecoration(
              labelText: 'Afiliacion / Institucion',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ],
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Guardar tipo'),
          ),
        ),
      ],
    );
  }
}
