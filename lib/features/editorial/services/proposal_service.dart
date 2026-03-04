import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service layer for the species change proposal workflow.
///
/// Roles:
///   editor  → submit / withdraw proposals
///   curator → review proposals + validate AI feedback corrections
///   admin   → approve / reject proposals (changes applied atomically via RPC)
class ProposalService {
  static final _db = Supabase.instance.client;

  // ── Editor ──────────────────────────────────────────────────────────────────

  /// Submit a change proposal for [speciesId].
  ///
  /// [changes] format: {"field_name": {"old": oldValue, "new": newValue}}
  /// Only include fields that actually changed.
  static Future<void> submit({
    required int speciesId,
    required Map<String, dynamic> changes,
    String? editorNotes,
  }) async {
    await _db.from('species_change_proposals').insert({
      'species_id': speciesId,
      'editor_id': _db.auth.currentUser!.id,
      'changes': changes,
      'editor_notes': editorNotes,
    });
  }

  /// Withdraw own pending proposal (sets status → 'withdrawn').
  static Future<void> withdraw(int proposalId) async {
    await _db
        .from('species_change_proposals')
        .update({'status': 'withdrawn'})
        .eq('id', proposalId)
        .eq('status', 'pending')
        .eq('editor_id', _db.auth.currentUser!.id);
  }

  /// Fetch the current user's own proposals (all statuses).
  static Future<List<Map<String, dynamic>>> fetchMyProposals() async {
    final data = await _db
        .from('species_change_proposals')
        .select('*, species(common_name_es, common_name_en, scientific_name)')
        .eq('editor_id', _db.auth.currentUser!.id)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data as List);
  }

  // ── Curator / Admin ──────────────────────────────────────────────────────────

  /// Fetch all pending proposals (visible to curator + admin).
  static Future<List<Map<String, dynamic>>> fetchPendingProposals() async {
    final data = await _db
        .from('species_change_proposals')
        .select('*, species(common_name_es, scientific_name)')
        .eq('status', 'pending')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data as List);
  }

  // ── Curator ──────────────────────────────────────────────────────────────────

  /// Mark a proposal with curator's scientific opinion.
  ///
  /// [status] must be 'curator_approved' or 'curator_flagged'.
  static Future<void> curatorReview(
    int proposalId,
    String status, {
    String? notes,
  }) async {
    await _db.rpc('curator_review_proposal', params: {
      'p_id': proposalId,
      'p_status': status,
      'p_notes': notes,
    });
  }

  /// Fetch AI feedback corrections pending curator validation.
  static Future<List<Map<String, dynamic>>> fetchPendingFeedback() async {
    final data = await _db
        .from('species_recognition_feedback')
        .select('*, '
            'predicted:species!predicted_species_id(common_name_es, scientific_name), '
            'correct:species!correct_species_id(common_name_es, scientific_name)')
        .isFilter('is_curator_validated', null)
        .eq('is_correction', true)
        .order('created_at', ascending: false)
        .limit(100);
    return List<Map<String, dynamic>>.from(data as List);
  }

  /// Validate (or reject) an AI correction.
  ///
  /// [isValid] = true means the user's correction was correct;
  ///             false means the AI was actually right.
  static Future<void> validateFeedback(
    int feedbackId,
    bool isValid, {
    String? notes,
  }) async {
    await _db.rpc('validate_ai_feedback', params: {
      'p_id': feedbackId,
      'p_validated': isValid,
      'p_notes': notes,
    });
  }

  // ── Admin ────────────────────────────────────────────────────────────────────

  /// Approve a proposal — atomically applies all changes to species table.
  static Future<void> approve(int proposalId, {String? notes}) async {
    await _db.rpc('approve_species_proposal', params: {
      'p_id': proposalId,
      'p_notes': notes,
    });
  }

  /// Reject a proposal. [notes] is required (must give a reason).
  static Future<void> reject(int proposalId, String notes) async {
    await _db.rpc('reject_species_proposal', params: {
      'p_id': proposalId,
      'p_notes': notes,
    });
  }
}

// ── Riverpod providers ────────────────────────────────────────────────────────

final myProposalsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return [];
  return ProposalService.fetchMyProposals();
});

final pendingProposalsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ProposalService.fetchPendingProposals();
});

final pendingFeedbackProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ProposalService.fetchPendingFeedback();
});
