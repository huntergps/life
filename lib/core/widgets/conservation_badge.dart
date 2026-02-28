import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';

class ConservationBadge extends StatelessWidget {
  final String status;
  final bool compact;

  const ConservationBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.t.species.conservationStatusLabel(status: _statusLabel(context)),
      child: Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 10,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: _statusColor,
        borderRadius: BorderRadius.circular(compact ? 4 : 6),
      ),
      child: Text(
        compact ? status : _statusLabel(context),
        style: TextStyle(
          color: _textColor,
          fontSize: compact ? 10 : 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    );
  }

  Color get _statusColor {
    return switch (status) {
      'EX' => AppColors.statusEX,
      'EW' => AppColors.statusEW,
      'CR' => AppColors.statusCR,
      'EN' => AppColors.statusEN,
      'VU' => AppColors.statusVU,
      'NT' => AppColors.statusNT,
      'LC' => AppColors.statusLC,
      'DD' => AppColors.statusDD,
      _ => AppColors.statusNE,
    };
  }

  Color get _textColor {
    return switch (status) {
      'DD' || 'NE' => Colors.black87,
      _ => Colors.white,
    };
  }

  String _statusLabel(BuildContext context) {
    final c = context.t.conservation;
    return switch (status) {
      'EX' => c.EX,
      'EW' => c.EW,
      'CR' => c.CR,
      'EN' => c.EN,
      'VU' => c.VU,
      'NT' => c.NT,
      'LC' => c.LC,
      'DD' => c.DD,
      _ => c.NE,
    };
  }
}
