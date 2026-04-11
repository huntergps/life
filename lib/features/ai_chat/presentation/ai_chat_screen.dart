import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/app/theme/app_colors.dart';
import 'package:galapagos_wildlife/app/theme/app_spacing.dart';
import 'package:galapagos_wildlife/features/species/photo_id/providers/gemma_model_provider.dart';
import 'package:galapagos_wildlife/features/species/photo_id/services/gemma_species_service.dart';
import 'package:galapagos_wildlife/features/ai_chat/services/ai_chat_service.dart';

// ─── Chat message model ─────────────────────────────────────────────────────

class _ChatMessage {
  final String text;
  final bool isUser;
  final Uint8List? image;
  final DateTime timestamp;

  _ChatMessage({required this.text, required this.isUser, this.image})
      : timestamp = DateTime.now();
}

// ─── Screen ─────────────────────────────────────────────────────────────────

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen>
    with TickerProviderStateMixin {
  final List<_ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;

  bool get _isEs => LocaleSettings.currentLocale == AppLocale.es;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    AiChatService.resetChat();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendText(String text) async {
    if (text.trim().isEmpty) return;
    _controller.clear();

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isProcessing = true;
    });
    _scrollToBottom();

    try {
      final response = await AiChatService.sendMessage(text);
      setState(() {
        _messages.add(_ChatMessage(text: response, isUser: false));
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage(
          text: _isEs ? 'Error al procesar: $e' : 'Processing error: $e',
          isUser: false,
        ));
        _isProcessing = false;
      });
    }
    _scrollToBottom();
  }

  Future<void> _sendWithImage(Uint8List imageBytes, String text) async {
    setState(() {
      _messages.add(_ChatMessage(
        text: text.isEmpty
            ? (_isEs ? 'Que es esto?' : 'What is this?')
            : text,
        isUser: true,
        image: imageBytes,
      ));
      _isProcessing = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final response =
          await AiChatService.sendMessage(text, image: imageBytes);
      setState(() {
        _messages.add(_ChatMessage(text: response, isUser: false));
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage(
          text: _isEs ? 'Error al procesar: $e' : 'Processing error: $e',
          isUser: false,
        ));
        _isProcessing = false;
      });
    }
    _scrollToBottom();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1280,
        maxHeight: 720,
        imageQuality: 85,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      await _sendWithImage(bytes, _controller.text.trim());
    } catch (e) {
      debugPrint('Image pick failed: $e');
    }
  }

  void _handleSuggestion(String text) {
    _sendText(text);
  }

  void _resetConversation() {
    AiChatService.resetChat();
    setState(() => _messages.clear());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final modelStatus = ref.watch(gemmaModelStatusProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.eco, size: 22, color: AppColors.primaryLight),
            const SizedBox(width: 8),
            Text(_isEs ? 'Guia IA' : 'AI Guide'),
          ],
        ),
        actions: [
          if (_messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: _isEs ? 'Nueva conversacion' : 'New conversation',
              onPressed: _resetConversation,
            ),
        ],
      ),
      body: Column(
        children: [
          // Model not available banner
          modelStatus.when(
            data: (status) {
              if (status == GemmaModelStatus.ready) {
                return const SizedBox.shrink();
              }
              return _ModelBanner(status: status, isEs: _isEs);
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Chat messages or empty state
          Expanded(
            child: _messages.isEmpty
                ? _EmptyState(
                    isEs: _isEs,
                    isDark: isDark,
                    onSuggestion: _handleSuggestion,
                  )
                : _MessageList(
                    messages: _messages,
                    isProcessing: _isProcessing,
                    isDark: isDark,
                    scrollController: _scrollController,
                  ),
          ),

          // Input bar
          modelStatus.when(
            data: (status) {
              if (status != GemmaModelStatus.ready) {
                return const SizedBox.shrink();
              }
              return _InputBar(
                controller: _controller,
                isProcessing: _isProcessing,
                isDark: isDark,
                isEs: _isEs,
                onSend: (text) => _sendText(text),
                onCamera: () => _pickImage(ImageSource.camera),
                onGallery: () => _pickImage(ImageSource.gallery),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ─── Model not downloaded banner ────────────────────────────────────────────

class _ModelBanner extends StatelessWidget {
  final GemmaModelStatus status;
  final bool isEs;

  const _ModelBanner({required this.status, required this.isEs});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String message;
    IconData icon;
    Color color;

    switch (status) {
      case GemmaModelStatus.notDownloaded:
        message = isEs
            ? 'Descarga la IA Mejorada en Ajustes para usar esta funcion'
            : 'Download Enhanced AI in Settings to use this feature';
        icon = Icons.download;
        color = Colors.orange;
      case GemmaModelStatus.downloading:
        message = isEs ? 'Descargando modelo...' : 'Downloading model...';
        icon = Icons.downloading;
        color = Colors.blue;
      case GemmaModelStatus.unsupported:
        message = isEs
            ? 'Tu dispositivo no soporta esta funcion'
            : 'Your device does not support this feature';
        icon = Icons.warning_amber;
        color = Colors.red;
      case GemmaModelStatus.ready:
        return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: color.withValues(alpha: isDark ? 0.2 : 0.1),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
          if (status == GemmaModelStatus.notDownloaded)
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed('/settings'),
              child: Text(
                isEs ? 'Ir a Ajustes' : 'Go to Settings',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Empty state with suggestions ───────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool isEs;
  final bool isDark;
  final ValueChanged<String> onSuggestion;

  const _EmptyState({
    required this.isEs,
    required this.isDark,
    required this.onSuggestion,
  });

  @override
  Widget build(BuildContext context) {
    final suggestions = isEs
        ? [
            'Que especies puedo ver hoy?',
            'Cuentame sobre las iguanas marinas',
            'Es seguro nadar aqui?',
            'Cual es el animal mas raro de Galapagos?',
          ]
        : [
            'What species can I see today?',
            'Tell me about marine iguanas',
            'Is it safe to swim here?',
            "What's the rarest animal in Galapagos?",
          ];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.eco,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isEs
                  ? 'Tu guia naturalista personal'
                  : 'Your personal naturalist guide',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isEs
                  ? 'Toma una foto o pregunta sobre la vida silvestre de Galapagos'
                  : 'Take a photo or ask about Galapagos wildlife',
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black54,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: suggestions
                  .map((s) => _SuggestionChip(
                        text: s,
                        isDark: isDark,
                        onTap: () => onSuggestion(s),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String text;
  final bool isDark;
  final VoidCallback onTap;

  const _SuggestionChip({
    required this.text,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? AppColors.darkCard : Colors.grey.shade100,
      borderRadius: AppSpacing.borderRadiusMd,
      child: InkWell(
        borderRadius: AppSpacing.borderRadiusMd,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Message list ───────────────────────────────────────────────────────────

class _MessageList extends StatelessWidget {
  final List<_ChatMessage> messages;
  final bool isProcessing;
  final bool isDark;
  final ScrollController scrollController;

  const _MessageList({
    required this.messages,
    required this.isProcessing,
    required this.isDark,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      itemCount: messages.length + (isProcessing ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length && isProcessing) {
          return _TypingIndicator(isDark: isDark);
        }
        return _MessageBubble(
          message: messages[index],
          isDark: isDark,
        );
      },
    );
  }
}

// ─── Single message bubble ──────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  final bool isDark;

  const _MessageBubble({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final alignment = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final margin = isUser
        ? const EdgeInsets.only(left: 48, bottom: 8)
        : const EdgeInsets.only(right: 48, bottom: 8);

    final bubbleColor = isUser
        ? AppColors.primary
        : (isDark ? AppColors.darkCard : Colors.grey.shade200);
    final textColor = isUser
        ? Colors.white
        : (isDark ? Colors.white : Colors.black87);

    return Container(
      margin: margin,
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(
                          alpha: isDark ? 0.3 : 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.eco,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Gemma',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white38 : Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isUser ? 16 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 16),
              ),
              border: isUser
                  ? null
                  : Border.all(
                      color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
                    ),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.image != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        message.image!,
                        width: 160,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                SelectableText(
                  message.text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2, left: 4, right: 4),
            child: Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.white24 : Colors.black26,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ─── Typing indicator (three animated dots) ─────────────────────────────────

class _TypingIndicator extends StatefulWidget {
  final bool isDark;
  const _TypingIndicator({required this.isDark});

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 48, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primary
                        .withValues(alpha: widget.isDark ? 0.3 : 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.eco, size: 14, color: AppColors.primary),
                ),
                const SizedBox(width: 6),
                Text(
                  'Gemma',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: widget.isDark ? Colors.white38 : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.isDark ? AppColors.darkCard : Colors.grey.shade200,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(
                color: widget.isDark
                    ? AppColors.darkBorder
                    : Colors.grey.shade300,
              ),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final delay = i * 0.2;
                    final t = (_controller.value - delay).clamp(0.0, 1.0);
                    // Sine wave for smooth bounce
                    final offset = -4 * _bounce(t);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Transform.translate(
                        offset: Offset(0, offset),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.primary
                                .withValues(alpha: 0.4 + 0.4 * _bounce(t)),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  double _bounce(double t) {
    // Simple sine bump at the beginning of cycle
    if (t < 0.5) {
      return (t * 2).clamp(0.0, 1.0);
    }
    return ((1 - t) * 2).clamp(0.0, 1.0);
  }
}

// ─── Input bar ──────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isProcessing;
  final bool isDark;
  final bool isEs;
  final ValueChanged<String> onSend;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  const _InputBar({
    required this.controller,
    required this.isProcessing,
    required this.isDark,
    required this.isEs,
    required this.onSend,
    required this.onCamera,
    required this.onGallery,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        8,
        8,
        8,
        MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Camera button
          IconButton(
            icon: Icon(
              Icons.camera_alt_outlined,
              color: isProcessing
                  ? (isDark ? Colors.white24 : Colors.black26)
                  : AppColors.primary,
            ),
            onPressed: isProcessing ? null : onCamera,
            tooltip: isEs ? 'Tomar foto' : 'Take photo',
          ),
          // Gallery button
          IconButton(
            icon: Icon(
              Icons.photo_library_outlined,
              color: isProcessing
                  ? (isDark ? Colors.white24 : Colors.black26)
                  : AppColors.primary,
            ),
            onPressed: isProcessing ? null : onGallery,
            tooltip: isEs ? 'Galeria' : 'Gallery',
          ),
          // Text field
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
                ),
              ),
              child: TextField(
                controller: controller,
                maxLines: null,
                textInputAction: TextInputAction.newline,
                enabled: !isProcessing,
                decoration: InputDecoration(
                  hintText: isEs ? 'Pregunta algo...' : 'Ask something...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white30 : Colors.black38,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                onSubmitted: isProcessing ? null : onSend,
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Send button
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(bottom: 2),
            child: Material(
              color: isProcessing
                  ? (isDark ? Colors.white12 : Colors.grey.shade300)
                  : AppColors.primary,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: isProcessing
                    ? null
                    : () {
                        final text = controller.text.trim();
                        if (text.isNotEmpty) onSend(text);
                      },
                child: Icon(
                  Icons.send,
                  size: 18,
                  color: isProcessing
                      ? (isDark ? Colors.white24 : Colors.white54)
                      : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
