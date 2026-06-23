// module_detail_page.dart
// Berisi: GroqService, SimulatedVideoPlayer, AiTutorChat, ModuleDetailPage
// Pasangan: materi_page.dart
// ✅ Light/Dark mode via AppTheme (provider)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kursuskilat/providers/app_data_provider.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'app_theme.dart';
import 'materi_page.dart'; // ← import models, buildModules, color tokens
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// ── CONFIG ───────────────────────────────────────────────────────────────────
const _kApiKey = String.fromEnvironment('GROQ_API_KEY', defaultValue: '');
const _kModel  = 'llama-3.3-70b-versatile';

// ── ACCENT COLORS (light mode legacy) ────────────────────────────────────────
const _blue   = Color(0xFF4E9DFF);
const _iris   = Color(0xFF7B9FFF);
const _purple = Color(0xFF9B6FE8);
const _orange = Color(0xFFFF9F43);

// ── GROQ SERVICE ──────────────────────────────────────────────────────────────
class GroqService {
  static const _url = 'https://api.groq.com/openai/v1/chat/completions';

  static Future<String> sendMessage({
    required List<Map<String, String>> history,
    required String userMessage,
    required String courseTitle,
    required String moduleName,
    required String subTitle,
  }) async {
    final sys = 'Kamu adalah I.R.I.S., tutor AI dari KursusKilat.\n'
        'Mata pelajaran: $courseTitle | Materi lanjutan: $moduleName | Bacaan: $subTitle\n'
        'Jawab dalam bahasa Indonesia, singkat, dan fokus pada teori komputer. '
        'Utamakan konsep untuk soal pilihan ganda, bukan langkah praktik.';

    final res = await http
        .post(
      Uri.parse(_url),
      headers: {
        'Authorization': 'Bearer $_kApiKey',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'model': _kModel,
        'max_tokens': 1024,
        'temperature': 0.8,
        'messages': [
          {'role': 'system', 'content': sys},
          ...history,
          {'role': 'user', 'content': userMessage}
        ]
      }),
    )
        .timeout(const Duration(seconds: 30),
        onTimeout: () => throw Exception('Timeout — coba lagi.'));

    if (res.statusCode == 200) {
      return jsonDecode(utf8.decode(res.bodyBytes))['choices'][0]['message']
      ['content'] as String;
    }
    throw Exception(res.statusCode == 401
        ? 'API Key invalid.'
        : res.statusCode == 429
        ? 'Rate limit. Tunggu sebentar.'
        : 'Error ${res.statusCode}');
  }
}

class YouTubePlayerWidget extends StatefulWidget {
  final String? youtubeVideoId;
  const YouTubePlayerWidget({super.key, required this.youtubeVideoId});

  @override
  State<YouTubePlayerWidget> createState() => _YouTubePlayerWidgetState();
}

class _YouTubePlayerWidgetState extends State<YouTubePlayerWidget> {
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    if (widget.youtubeVideoId != null && widget.youtubeVideoId!.isNotEmpty) {
      _controller = YoutubePlayerController(
        initialVideoId: widget.youtubeVideoId!,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          enableCaption: false,
        ),
      );
    }
  }

  @override
  void didUpdateWidget(covariant YouTubePlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.youtubeVideoId != oldWidget.youtubeVideoId) {
      _controller?.dispose();
      _controller = null;
      _initializePlayer();
      setState(() {}); // Rebuild to show the new player or placeholder
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      // Placeholder when URL is empty or invalid
      final t = context.watch<AppTheme>();
      return Container(
        height: 200, // Adjust height as needed
        decoration: BoxDecoration(
          color: t.isDark ? const Color(0xFF0D0D18) : t.surfaceB,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.ondemand_video_rounded, color: t.textMid, size: 50),
              const SizedBox(height: 10),
              Text(
                'Tidak ada video pengantar',
                style: TextStyle(color: t.textMid, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    } else {
      return YoutubePlayer(
        controller: _controller!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppTheme.green,
        onReady: () {},
        // onEnded: (metaData) {},
      );
    }
  }
}

// ── SIMULATED VIDEO PLAYER (now just a placeholder for non-YouTube or empty URLs) ──────────────────────────────────
class SimulatedVideoPlayer extends StatelessWidget {
  final String title, emoji;
  final Color accentColor;
  final String introVideoUrl; // Keep this for potential future non-YouTube videos
  final VoidCallback? onComplete;
  const SimulatedVideoPlayer({
    super.key,
    required this.title,
    required this.emoji,
    required this.accentColor,
    this.introVideoUrl = '',
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();
    String? youtubeVideoId = YoutubePlayer.convertUrlToId(introVideoUrl);

    if (youtubeVideoId != null) {
      return YouTubePlayerWidget(youtubeVideoId: youtubeVideoId);
    } else {
      // Existing placeholder for empty or non-YouTube URLs
      return Container(
        decoration: BoxDecoration(
          color: t.isDark ? const Color(0xFF0D0D18) : t.surfaceB,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor.withValues(alpha: 0.3)),
        ),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(children: [
              Container(
                  decoration: BoxDecoration(
                      color: t.isDark
                          ? t.surfaceB
                          : null,
                      gradient: t.isDark
                          ? null
                          : LinearGradient(
                              colors: [
                                accentColor.withValues(alpha: 0.10),
                                t.surfaceB,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                  ),
              ),
              Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 56)),
                        const SizedBox(height: 12),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: t.textPri,
                              fontSize: 15,
                              fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        if (introVideoUrl.isNotEmpty)
                          _badge(
                            t.isDark ? t.secondary : AppTheme.cyan,
                            'URL VIDEO TERHUBUNG',
                          ),
                        const SizedBox(height: 4),
                        Text(
                          'Video tidak tersedia atau tidak didukung',
                          style: TextStyle(color: t.textMid, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
            ]),
          ),
        ),
      );
    }
  }

  Widget _badge(Color c, String text) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
          color: c.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.withValues(alpha: 0.4))),
      child: Text(text,
          style: TextStyle(
              color: c,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2)));
}




// ── AI TUTOR CHAT ─────────────────────────────────────────────────────────────
class AiTutorChat extends StatefulWidget {
  final String courseTitle, moduleName, subTitle;
  const AiTutorChat({
    super.key,
    required this.courseTitle,
    required this.moduleName,
    required this.subTitle,
  });

  @override
  State<AiTutorChat> createState() => _AiTutorChatState();
}

class _AiTutorChatState extends State<AiTutorChat> {
  final _msgs = <Map<String, dynamic>>[];
  final _history = <Map<String, String>>[];
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  bool _typing = false, _expanded = false;
  final _quick = [
    'Jelaskan sekali lagi',
    'Beri contoh nyata',
    'Ada tips lain?',
    'Kenapa ini penting?'
  ];

  @override
  void initState() {
    super.initState();
    _msgs.add({
      'isUser': false,
      'text':
      '...memindai konteks.\n\nAku sudah baca **${widget.subTitle}**. Ada yang membingungkan?'
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollDown() =>
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(_scroll.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut);
        }
      });

  Future<void> _send(String text) async {
    if (text.trim().isEmpty || _typing) return;
    _ctrl.clear();
    setState(() {
      _msgs.add({'isUser': true, 'text': text.trim()});
      _msgs.add({'isUser': false, 'text': '', 'isLoading': true});
      _typing = true;
    });
    _scrollDown();
    try {
      final reply = await GroqService.sendMessage(
          history: _history,
          userMessage: text.trim(),
          courseTitle: widget.courseTitle,
          moduleName: widget.moduleName,
          subTitle: widget.subTitle);
      _history.addAll([
        {'role': 'user', 'content': text.trim()},
        {'role': 'assistant', 'content': reply}
      ]);
      setState(() {
        _msgs.removeLast();
        _msgs.add({'isUser': false, 'text': reply});
      });
    } catch (e) {
      setState(() {
        _msgs.removeLast();
        _msgs.add({
          'isUser': false,
          'text': '⚠️ ${e.toString().replaceAll('Exception: ', '')}'
        });
      });
    }
    setState(() => _typing = false);
    _scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();

    return Container(
      decoration: BoxDecoration(
          color: t.surfaceB,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _iris.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
                color: _iris.withValues(alpha: t.isDark ? 0.08 : 0.05),
                blurRadius: 20,
                offset: const Offset(0, 4))
          ]),
      child: Column(children: [
        // ── Header / toggle ──
        GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                    color: t.isDark
                        ? AppTheme.iris.withValues(alpha: 0.12)
                        : null,
                    gradient: t.isDark
                        ? null
                        : LinearGradient(colors: [
                            const Color(0xFF4A6FD4).withValues(alpha: 0.1),
                            _purple.withValues(alpha: 0.07),
                          ]),
                    borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(_expanded ? 0 : 16),
                        bottomRight: Radius.circular(_expanded ? 0 : 16))),
                child: Row(children: [
                  Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                          color: t.isDark ? AppTheme.iris : null,
                          gradient: t.isDark
                              ? null
                              : const LinearGradient(
                                  colors: [
                                    Color(0xFF4A6FD4),
                                    Color(0xFF9B6FE8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Center(
                          child:
                          Text('🔍', style: TextStyle(fontSize: 15)))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('I.R.I.S. — Tanya AI Tutor',
                                style: TextStyle(
                                    color: t.textPri,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800)),
                            Text(
                                'Aktif | Siap menjelaskan ${widget.subTitle}',
                                style: TextStyle(
                                    color: t.textMid, fontSize: 10),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ])),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: _iris.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(_expanded ? '▲ Tutup' : '▼ Buka',
                          style: const TextStyle(
                              color: _iris,
                              fontSize: 10,
                              fontWeight: FontWeight.w700))),
                ]))),

        // ── Expandable chat body ──
        AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _expanded
                ? Column(children: [
              // Quick replies
              Container(
                  height: 38,
                  decoration: BoxDecoration(
                      color: t.surface.withValues(alpha: 0.5),
                      border: Border(
                          bottom: BorderSide(color: t.divider))),
                  child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      separatorBuilder: (_, _) =>
                      const SizedBox(width: 6),
                      itemCount: _quick.length,
                      itemBuilder: (_, i) => GestureDetector(
                          onTap: () => _send(_quick[i]),
                          child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                  color:
                                  _iris.withValues(alpha: 0.1),
                                  borderRadius:
                                  BorderRadius.circular(14),
                                  border: Border.all(
                                      color: _iris
                                          .withValues(alpha: 0.25))),
                              child: Text(_quick[i],
                                  style: const TextStyle(
                                      color: _iris,
                                      fontSize: 10,
                                      fontWeight:
                                      FontWeight.w600)))))),

              // Messages
              SizedBox(
                  height: 260,
                  child: ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.all(12),
                      physics: const BouncingScrollPhysics(),
                      itemCount: _msgs.length,
                      itemBuilder: (ctx, i) {
                        final m = _msgs[i];
                        final isUser = m['isUser'] as bool;
                        final loading =
                            m['isLoading'] as bool? ?? false;
                        return Padding(
                            padding:
                            const EdgeInsets.only(bottom: 10),
                            child: Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.end,
                                mainAxisAlignment: isUser
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  if (!isUser) ...[
                                    Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                            color: t.isDark
                                                ? AppTheme.iris
                                                : null,
                                            gradient: t.isDark
                                                ? null
                                                : const LinearGradient(
                                                    colors: [
                                                      Color(0xFF4A6FD4),
                                                      Color(0xFF9B6FE8),
                                                    ],
                                                  ),
                                            borderRadius:
                                            BorderRadius.circular(
                                                8)),
                                        child: const Center(
                                            child: Text('🔍',
                                                style: TextStyle(
                                                    fontSize: 11)))),
                                    const SizedBox(width: 6),
                                  ],
                                  Flexible(
                                      child: Container(
                                          padding: const EdgeInsets
                                              .symmetric(
                                              horizontal: 10,
                                              vertical: 8),
                                          decoration: BoxDecoration(
                                              color: isUser
                                                  ? (t.isDark
                                                      ? AppTheme.irisDk
                                                      : null)
                                                  : (t.isDark
                                                      ? t.surfaceB
                                                      : t.surface),
                                              gradient: isUser && !t.isDark
                                                  ? const LinearGradient(
                                                      colors: [
                                                        Color(0xFF4A6FD4),
                                                        Color(0xFF7B5FCC),
                                                      ],
                                                      begin: Alignment
                                                          .topLeft,
                                                      end: Alignment
                                                          .bottomRight,
                                                    )
                                                  : null,
                                              borderRadius:
                                              BorderRadius.only(
                                                topLeft:
                                                const Radius.circular(
                                                    12),
                                                topRight:
                                                const Radius.circular(
                                                    12),
                                                bottomLeft:
                                                Radius.circular(
                                                    isUser ? 12 : 3),
                                                bottomRight:
                                                Radius.circular(
                                                    isUser ? 3 : 12),
                                              ),
                                              border: isUser
                                                  ? null
                                                  : Border.all(
                                                  color: _iris
                                                      .withValues(alpha: 
                                                      0.2))),
                                          child: loading
                                              ? _LoadingDots()
                                              : _RichText(
                                              text: m['text']
                                              as String,
                                              isUser: isUser))),
                                ]));
                      })),

              // Input bar
              Container(
                  padding:
                  const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(color: t.divider))),
                  child: Row(children: [
                    Expanded(
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12),
                            decoration: BoxDecoration(
                                color: t.surface,
                                borderRadius:
                                BorderRadius.circular(20),
                                border: Border.all(
                                    color: _typing
                                        ? _iris.withValues(alpha: 0.4)
                                        : t.divider)),
                            child: TextField(
                                controller: _ctrl,
                                style: TextStyle(
                                    color: t.textPri,
                                    fontSize: 12),
                                maxLines: 2,
                                minLines: 1,
                                textInputAction:
                                TextInputAction.send,
                                onSubmitted: (txt) {
                                  if (!_typing) _send(txt);
                                },
                                decoration: InputDecoration(
                                    hintText:
                                    'Tanya sesuatu...',
                                    hintStyle: TextStyle(
                                        color: t.textMid,
                                        fontSize: 11),
                                    border: InputBorder.none,
                                    contentPadding:
                                    const EdgeInsets.symmetric(
                                        vertical: 9))))),
                    const SizedBox(width: 8),
                    GestureDetector(
                        onTap: _typing
                            ? null
                            : () => _send(_ctrl.text),
                        child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.circular(11),
                                color: _typing
                                    ? t.surfaceB
                                    : (t.isDark ? AppTheme.iris : null),
                                gradient: _typing || t.isDark
                                    ? null
                                    : const LinearGradient(
                                    colors: [
                                      Color(0xFF4A6FD4),
                                      Color(0xFF9B6FE8)
                                    ],
                                    begin: Alignment.topLeft,
                                    end:
                                    Alignment.bottomRight),
                                boxShadow: _typing
                                    ? null
                                    : [
                                  BoxShadow(
                                      color: _iris
                                          .withValues(alpha: 0.3),
                                      blurRadius: 8)
                                ]),
                            child: Icon(
                                _typing
                                    ? Icons.hourglass_top_rounded
                                    : Icons.send_rounded,
                                color: _typing
                                    ? t.textMid
                                    : Colors.white,
                                size: 16))),
                  ])),
            ])
                : const SizedBox.shrink()),
      ]),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();
    return AnimatedBuilder(
        animation: _c,
        builder: (_, _) => Row(mainAxisSize: MainAxisSize.min, children: [
          Text('memproses',
              style: TextStyle(color: t.textMid, fontSize: 10)),
          const SizedBox(width: 4),
          ...List.generate(3, (i) {
            final p = (_c.value - i / 3).clamp(0.0, 1.0);
            final op =
            (p < 0.5 ? p * 2 : (1 - p) * 2).clamp(0.3, 1.0);
            return Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 1.5),
                child: Opacity(
                    opacity: op,
                    child: Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                            color: _iris,
                            shape: BoxShape.circle))));
          }),
        ]));
  }
}

class _RichText extends StatelessWidget {
  final String text;
  final bool isUser;
  const _RichText({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();
    final base = isUser ? Colors.white.withValues(alpha: 0.95) : t.textPri;
    final spans = <InlineSpan>[];
    final lines = text.split('\n');
    for (int li = 0; li < lines.length; li++) {
      if (li > 0) spans.add(const TextSpan(text: '\n'));
      String rem = lines[li];
      while (rem.isNotEmpty) {
        final bM = RegExp(r'\*\*(.*?)\*\*').firstMatch(rem);
        final cM = RegExp(r'`(.*?)`').firstMatch(rem);
        RegExpMatch? first;
        String? type;
        if (bM != null) { first = bM; type = 'b'; }
        if (cM != null && (first == null || cM.start < first.start)) {
          first = cM; type = 'c';
        }
        if (first == null) {
          spans.add(TextSpan(
              text: rem,
              style: TextStyle(color: base, fontSize: 12, height: 1.5)));
          break;
        }
        if (first.start > 0) {
          spans.add(TextSpan(
              text: rem.substring(0, first.start),
              style: TextStyle(color: base, fontSize: 12, height: 1.5)));
        }
        final inner = first.group(1)!;
        if (type == 'b') {
          spans.add(TextSpan(
              text: inner,
              style: TextStyle(
                  color: isUser ? Colors.white : _iris,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  height: 1.5)));
        } else {
          spans.add(WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                      color: t.isDark
                          ? const Color(0xFF0D0D18)
                          : t.surfaceB,
                      borderRadius: BorderRadius.circular(4),
                      border:
                      Border.all(color: _iris.withValues(alpha: 0.3))),
                  child: Text(inner,
                      style: TextStyle(
                          color: isUser ? Colors.white70 : AppTheme.iris,
                          fontSize: 10,
                          fontFamily: 'monospace')))));
        }
        rem = rem.substring(first.start + first.group(0)!.length);
      }
    }
    return RichText(text: TextSpan(children: spans));
  }
}

// ── MODULE DETAIL PAGE ─────────────────────────────────────────────────────────
class ModuleDetailPage extends StatefulWidget {
  final KursusData course;
  final int? initialModuleIndex;
  const ModuleDetailPage({
    super.key,
    required this.course,
    this.initialModuleIndex,
  });

  @override
  State<ModuleDetailPage> createState() => _ModuleDetailPageState();
}

class _ModuleDetailPageState extends State<ModuleDetailPage> {
  late List<ModulMateri> _modules;
  late int _mi;
  final _scroll = ScrollController();
  final _tabScroll = ScrollController();

  // Light mode: variasi warna per modul. Dark mode: hijau + iris saja.
  static const _accentPalette = [
    AppTheme.green,
    _blue,
    _orange,
    _purple,
    _iris,
  ];

  Color _moduleAccent(int i, AppTheme theme) {
    if (!theme.isDark) return _accentPalette[i % _accentPalette.length];
    return i.isEven ? AppTheme.green : AppTheme.iris;
  }

  @override
  void initState() {
    super.initState();
    _modules = buildModules(widget.course.title);
    _mi = _resolveInitialModuleIndex(_modules.length);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mi > 0) _scrollTabToIndex(_mi);
    });
  }

  int _resolveInitialModuleIndex(int moduleCount) {
    if (moduleCount == 0) return 0;
    final initial = widget.initialModuleIndex ?? 0;
    return initial.clamp(0, moduleCount - 1);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appData = context.watch<AppDataProvider>();
    if (appData.isLoaded &&
        appData.materialsByCourseId.containsKey(widget.course.id)) {
      final fromDb = appData.modulesForCourse(widget.course);
      if (fromDb.isNotEmpty) {
        _modules = fromDb;
        _mi = _resolveInitialModuleIndex(_modules.length);
      }
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    _scroll.dispose();
    _tabScroll.dispose();
    super.dispose();
  }

  ModulMateri get _mod => _modules[_mi.clamp(0, _modules.length - 1)];
  ModulMateri get _primaryModule => _modules.first;
  SubMateri get _sub => _mod.subMateri.first;
  SubMateri get _primarySub => _primaryModule.subMateri.first;
  Color _accentFor(AppTheme t) => _moduleAccent(_mi, t);
  Color _primaryAccentFor(AppTheme t) => _moduleAccent(0, t);

  void _selMod(int i) {
    if (i <= 0 || i >= _modules.length) return;
    setState(() => _mi = i);
    _scrollTabToIndex(i);
  }

  void _scrollTabToIndex(int i) {
    if (i <= 0) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_tabScroll.hasClients) {
        final target = (i - 1) * 130.0;
        _tabScroll.animateTo(
          target.clamp(0.0, _tabScroll.position.maxScrollExtent),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();
    return Scaffold(
      backgroundColor: t.bg,
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: Column(children: [
        _topNav(t),
        Expanded(child: _content(t)),
      ]),
    );
  }

  // ── Top navigation bar ──
  Widget _topNav(AppTheme t) {
    return Container(
      decoration: BoxDecoration(
          color: t.surface,
          border: Border(bottom: BorderSide(color: t.divider))),
      child: SafeArea(
          bottom: false,
          child: Column(children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Row(children: [
                  GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                              color: t.surfaceB,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: t.divider)),
                          child: Icon(Icons.arrow_back_ios_rounded,
                              color: t.textSec, size: 16))),
                  const SizedBox(width: 12),
                  Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                          color: widget.course.accentStart,
                          borderRadius: BorderRadius.circular(8)),
                      child: Center(
                          child: Text(widget.course.emoji,
                              style: const TextStyle(fontSize: 16)))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.course.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: t.textPri,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800)),
                            Text('Materi pembelajaran komputer',
                                style: TextStyle(
                                    color: t.textMid, fontSize: 10)),
                          ])),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: AppTheme.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppTheme.green.withValues(alpha: 0.25))),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.menu_book_rounded,
                            color: AppTheme.green, size: 13),
                        const SizedBox(width: 5),
                        Text('${_modules.length} materi',
                            style: const TextStyle(
                                color: AppTheme.green,
                                fontSize: 11,
                                fontWeight: FontWeight.w800)),
                      ])),
                ])),
          ])),
    );
  }

  // ── Module tab bar (materi lanjutan: indeks 1..n-1) ──
  Widget _moduleTabBar(AppTheme t) {
    if (_modules.length <= 1) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: t.divider)),
      child: SizedBox(
        height: 62,
        child: ListView.builder(
          controller: _tabScroll,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          itemCount: _modules.length - 1,
          itemBuilder: (_, li) {
            final i = li + 1;
            final m = _modules[i];
            final sel = i == _mi;
            final c = _moduleAccent(i, t);

            return GestureDetector(
              onTap: () => _selMod(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                decoration: BoxDecoration(
                  color: sel ? c.withValues(alpha: 0.15) : t.surfaceB,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: sel ? c.withValues(alpha: 0.5) : t.divider,
                    width: sel ? 1.5 : 1,
                  ),
                  boxShadow: sel
                      ? [BoxShadow(
                      color: c.withValues(alpha: 0.2), blurRadius: 8)]
                      : null,
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(m.emoji,
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Materi ${i + 1}',
                            style: TextStyle(
                                color: sel ? c : t.textMid,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8)),
                        const SizedBox(height: 1),
                        Text(m.title,
                            maxLines: 1,
                            style: TextStyle(
                                color: sel ? t.textPri : t.textSec,
                                fontSize: 11,
                                fontWeight: sel
                                    ? FontWeight.w700
                                    : FontWeight.w500)),
                      ]),
                ]),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Main scrollable content ──
  Widget _content(AppTheme t) {
    final aiModule = _mi > 0 ? _mod : _primaryModule;
    final aiSub = aiModule.subMateri.first;

    return SingleChildScrollView(
      controller: _scroll,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SimulatedVideoPlayer(
          title: widget.course.introVideoUrl.isNotEmpty
              ? 'Video Pengantar ${widget.course.title}'
              : 'Pengantar ${widget.course.title}',
          emoji: widget.course.emoji,
          accentColor: AppTheme.green,
          introVideoUrl: widget.course.introVideoUrl,
        ),
        const SizedBox(height: 16),
        _mainReading(t),
        if (_modules.length > 1) ...[
          const SizedBox(height: 16),
          Text('MATERI LANJUTAN',
              style: TextStyle(
                  color: t.textMid,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1)),
          const SizedBox(height: 8),
          _moduleTabBar(t),
        ],
        if (_mi > 0) ...[
          const SizedBox(height: 16),
          AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _subContent(t, key: ValueKey(_mi))),
        ],
        const SizedBox(height: 20),
        AiTutorChat(
            key: ValueKey('ai_${aiModule.title}_$_mi'),
            courseTitle: widget.course.title,
            moduleName: aiModule.title,
            subTitle: aiSub.title),
      ]),
    );
  }

  // ── Main reading body text ──
  String _mainReadingBody() {
    final title = widget.course.title.toLowerCase();
    if (title.contains('pemrograman')) {
      return 'Pemrograman adalah cara memberi instruksi logis kepada komputer agar sebuah masalah dapat dipecah menjadi langkah yang teratur. Konsep utamanya bukan sekadar menulis kode, tetapi memahami bagaimana data disimpan, bagaimana keputusan dibuat, dan bagaimana alur kerja program berjalan dari awal sampai akhir.\n\nDalam konteks soal pilihan ganda, dasar pemrograman biasanya menguji definisi variabel, tipe data, operator, kondisi, perulangan, dan fungsi. User perlu memahami perbedaan antar konsep tersebut agar tidak terjebak pada jawaban yang terlihat mirip.\n\nMateri pertama ini menjadi fondasi sebelum masuk ke materi lanjutan. Setelah memahami dasar alur logika, user akan lebih mudah menjawab soal yang menanyakan penyebab error logika, urutan eksekusi, atau pilihan struktur program yang paling tepat.';
    }
    if (title.contains('struktur data')) {
      return 'Struktur data adalah cara mengatur informasi agar mudah disimpan, dicari, diubah, dan dibandingkan. Algoritma adalah urutan langkah logis untuk menyelesaikan masalah dengan memanfaatkan struktur data tersebut. Keduanya saling terhubung karena pilihan struktur data dapat memengaruhi efisiensi algoritma.\n\nSoal pilihan ganda pada topik ini biasanya menanyakan karakteristik list, stack, queue, tree, graph, pencarian, pengurutan, dan kompleksitas. User tidak perlu menghafal kode, tetapi perlu memahami kapan sebuah konsep lebih tepat digunakan dibanding konsep lain.\n\nMateri pertama ini menekankan ide dasar efisiensi, urutan proses, dan hubungan antara data dengan langkah penyelesaian masalah. Dari sini user bisa lanjut membaca materi yang lebih spesifik.';
    }
    if (title.contains('basis data')) {
      return 'Basis data adalah sistem untuk menyimpan dan mengelola informasi agar data dapat dipakai kembali secara konsisten. Konsep pentingnya mencakup tabel, relasi, kunci, normalisasi, transaksi, dan integritas data. Semua konsep tersebut membantu data tetap rapi, tidak mudah ganda, dan mudah dicari.\n\nDalam soal pilihan ganda, topik basis data sering menguji perbedaan primary key dan foreign key, alasan normalisasi, fungsi transaksi, serta hubungan antar entitas. Jawaban yang benar biasanya dapat ditemukan dengan memahami tujuan dari setiap konsep, bukan dengan menghafal istilah saja.\n\nMateri pertama ini menjadi pengantar untuk memahami mengapa data perlu diatur dengan aturan tertentu sebelum digunakan oleh aplikasi.';
    }
    if (title.contains('jaringan')) {
      return 'Jaringan komputer adalah hubungan antar perangkat agar data dapat berpindah dari satu titik ke titik lain. Konsep dasarnya meliputi alamat jaringan, protokol komunikasi, model layer, routing, dan keamanan dasar. Setiap konsep menjelaskan bagaimana perangkat saling mengenali dan bertukar informasi.\n\nSoal pilihan ganda pada jaringan biasanya menanyakan fungsi protokol, perbedaan TCP dan UDP, alamat IP, DNS, HTTP, serta model OSI atau TCP/IP. User perlu memahami peran tiap konsep dalam proses komunikasi, bukan sekadar mengingat singkatan.\n\nMateri pertama ini menyiapkan dasar untuk membaca alur komunikasi data secara konseptual, mulai dari perangkat pengirim sampai data diterima perangkat tujuan.';
    }
    if (title.contains('buatan') || title.contains('ai')) {
      return 'Kecerdasan buatan adalah bidang ilmu komputer yang membahas cara membuat sistem mampu mengambil keputusan, mengenali pola, atau memberi rekomendasi berdasarkan data. Konsep dasarnya mencakup agen cerdas, data latih, model, fitur, prediksi, dan evaluasi hasil.\n\nDalam soal pilihan ganda, AI dan machine learning sering menguji perbedaan supervised, unsupervised, dan reinforcement learning, fungsi data, overfitting, akurasi, serta batasan model. User perlu memahami alur berpikirnya: data masuk, model belajar pola, lalu hasil dievaluasi.\n\nMateri pertama ini menjadi dasar sebelum masuk ke pembahasan yang lebih detail tentang data, model, dan cara menilai hasil AI.';
    }
    return '${widget.course.description}\n\nMateri ini disiapkan sebagai bacaan teori sebelum atau saat player mengerjakan soal pilihan ganda. Fokusnya adalah memahami definisi, fungsi, hubungan antar konsep, dan alasan sebuah konsep digunakan.\n\nGunakan bacaan utama ini sebagai fondasi, lalu lanjutkan ke daftar materi lanjutan untuk membaca pembahasan yang lebih spesifik.';
  }

  // ── Main reading card (selalu materi pertama / sort_order terkecil) ──
  Widget _mainReading(AppTheme t) {
    final s = _primarySub;
    final title = _primaryModule.title;
    final body = s.content.trim().isNotEmpty ? s.content : _mainReadingBody();

    return _card(
      t,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: AppTheme.green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6)),
            child: const Text('BACAAN UTAMA',
                style: TextStyle(
                    color: AppTheme.green,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1))),
        const SizedBox(height: 10),
        Text(title,
            style: TextStyle(
                color: t.textPri,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3)),
        const SizedBox(height: 8),
        Text(body,
            style: TextStyle(
                color: t.textSec, fontSize: 13, height: 1.7)),
        if (s.keyPoints.isNotEmpty) ...[
          const SizedBox(height: 14),
          _keyPointsSection(t, s.keyPoints, _primaryAccentFor(t)),
        ],
      ]),
    );
  }

  Widget _keyPointsSection(AppTheme t, List<String> points, Color accent) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6)),
            child: Text('POIN PENTING',
                style: TextStyle(
                    color: accent,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1))),
        const SizedBox(height: 10),
        ...points.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          shape: BoxShape.circle),
                      child: Center(
                          child: Text('${e.key + 1}',
                              style: TextStyle(
                                  color: accent,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800)))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(e.value,
                          style: TextStyle(
                              color: t.textSec,
                              fontSize: 13,
                              height: 1.5))),
                ]))),
      ]);

  // ── Sub content (selected module) ──
  Widget _subContent(AppTheme t, {Key? key}) {
    final s = _sub;
    return Column(
        key: key,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _card(
              t,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: _accentFor(t).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6)),
                        child: Text('MATERI TERPILIH',
                            style: TextStyle(
                                color: _accentFor(t),
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1))),
                    const SizedBox(height: 10),
                    Text(s.title,
                        style: TextStyle(
                            color: t.textPri,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3)),
                    const SizedBox(height: 10),
                    Text(s.content,
                        style: TextStyle(
                            color: t.textSec,
                            fontSize: 13,
                            height: 1.65)),
                  ])),
          if (s.keyPoints.isNotEmpty) ...[
            const SizedBox(height: 12),
            _card(t, child: _keyPointsSection(t, s.keyPoints, _accentFor(t))),
          ],
        ]);
  }

  // ── Generic card container ──
  Widget _card(AppTheme t, {required Widget child}) => Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: t.surfaceB,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: t.divider),
          boxShadow: t.isDark
              ? []
              : [
            BoxShadow(
                color: t.shadow.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 2))
          ]),
      child: child);
}