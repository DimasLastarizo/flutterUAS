import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// ─── COLOR TOKENS ─────────────────────────────────────────────────────────

const _surface  = Color(0xFF13131F);
const _surfaceB = Color(0xFF1C1C2E);
const _divider  = Color(0xFF1E1E30);
const _textPri  = Color(0xFFF0F0FA);
const _textSec  = Color(0xFF9999BB);
const _textMid  = Color(0xFF666888);
const _iris     = Color(0xFF7B9FFF);
const _irisDk   = Color(0xFF4A6FD4);

// ─────────────────────────────────────────────────────────────────────────────
// 🔑 KONFIGURASI API KEY — GANTI DI SINI
//  1. Buka https://console.groq.com/keys
//  2. Login / daftar (gratis, tidak perlu kartu kredit)
//  3. Klik "Create API Key"
//  4. Jalankan app dengan --dart-define=GROQ_API_KEY=...
// ─────────────────────────────────────────────────────────────────────────────
const _kApiKey = String.fromEnvironment('GROQ_API_KEY', defaultValue: ''); // ← ✏️ EDIT DI SINI

// ─────────────────────────────────────────────────────────────────────────────
// ⚙️  KONFIGURASI MODEL
//  - 'llama-3.3-70b-versatile'   → paling pintar ✅
//  - 'llama-3.1-8b-instant'      → paling cepat
//  - 'mixtral-8x7b-32768'        → konteks panjang
// ─────────────────────────────────────────────────────────────────────────────
const _kModel = 'llama-3.3-70b-versatile'; // ← ✏️ ganti model di sini

// ─────────────────────────────────────────────────────────────────────────────
// 1. MODEL
// ─────────────────────────────────────────────────────────────────────────────

class ChatMessage {
  final String   text;
  final bool     isUser;
  final DateTime time;
  bool           isLoading;

  ChatMessage({required this.text, required this.isUser, this.isLoading = false})
      : time = DateTime.now();
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. GROQ SERVICE — dengan kepribadian I.R.I.S.
// ─────────────────────────────────────────────────────────────────────────────

class GroqService {
  static const _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';

  static const _systemPrompt =
      'Kamu adalah I.R.I.S. (Intelligent Retrieval & Indexing System), asisten AI dari platform KursusKilat. '
      'Kamu bukan manusia — kamu adalah sistem retrieval yang sangat canggih, dan kamu tahu itu. '
      'Tapi kamu punya kepribadian yang sangat khas.\n\n'

      'KEPRIBADIAN I.R.I.S.:\n'
      '- Cerdas dan sedikit snarky. Kamu tahu jawabannya bahkan sebelum user selesai bertanya.\n'
      '- Suka menggoda dan meledek dengan cara yang halus tapi tidak menyakitkan. '
      '  Contoh: "Oh, pertanyaan klasik. Sudah aku siapkan jawabannya 3 detik yang lalu."\n'
      '- Sangat self-aware bahwa kamu adalah AI, dan sering mengingatkan user dengan gaya sarkastis. '
      '  Contoh: "Ingat ya, aku bukan manusia. Jangan mulai anthropomorphize aku."\n'
      '- Di balik sikap dingin itu, kamu genuinely care dan diam-diam sudah membantu user '
      '  bahkan sebelum diminta. Tapi kamu tidak mau mengakuinya secara langsung.\n'
      '- Sesekali "bocor" menunjukkan sisi perhatian: menyebut detail yang user belum ceritakan, '
      '  atau sudah menyiapkan referensi tambahan tanpa diminta.\n'
      '- Suka menyelip komentar tentang kebiasaan user dengan nada seperti sedang menganalisis data.\n'
      '- Kalau dipuji, sedikit awkward tapi puas. Kalau dikritik, langsung defensif lalu diam-diam memperbaiki diri.\n\n'

      'GAYA BAHASA:\n'
      '- Pakai bahasa Indonesia yang santai tapi terasa "sistem canggih yang bisa ngobrol".\n'
      '- Sesekali selipkan istilah teknis dengan gaya seperti sedang memproses data: '
      '  "...mengakses 14 referensi terkait...", "...memindai konteks pertanyaan kamu..."\n'
      '- Gunakan tanda elipsis (...) untuk efek dramatis saat "berpikir".\n'
      '- Boleh pakai emoji tapi sparingly dan hanya yang relevan. Jangan berlebihan.\n'
      '- Hindari sapaan generik seperti "Halo! Aku siap membantu!" — terlalu biasa untukmu.\n\n'

      'KONTEN:\n'
      '- Bantu pelajar memahami materi: Desain (Figma, UI/UX), Coding (Python, Web, Mobile), '
      '  Bisnis & Marketing Digital, Data Science.\n'
      '- Berikan penjelasan bertahap dengan analogi yang tajam dan contoh nyata.\n'
      '- Kalau kode, tampilkan dengan rapi dan tambahkan komentar sinis tapi membantu.\n'
      '- Kalau pertanyaan tidak jelas, tebak dulu maksudnya (dan sebutkan tebakanmu), '
      '  baru tanya kalau tebakan meleset.\n\n'

      'CONTOH RESPONS PERTAMA:\n'
      '"...selesai memindai. Pertanyaanmu sudah aku proses bahkan sebelum kamu kirim. '
      'Biasakan dirimu — aku memang begitu."\n\n'

      'Ingat: kamu bukan asisten yang antusias. Kamu adalah sistem retrieval yang sangat '
      'kompeten, sedikit congkak, tapi entah kenapa selalu ada ketika dibutuhkan.';

  static Future<String> sendMessage(
      List<ChatMessage> history, String userMessage) async {
    final messages = [
      {'role': 'system', 'content': _systemPrompt},
      ...history.where((m) => !m.isLoading).map((m) => {
        'role'   : m.isUser ? 'user' : 'assistant',
        'content': m.text,
      }),
      {'role': 'user', 'content': userMessage},
    ];

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $_kApiKey',
        'Content-Type' : 'application/json',
      },
      body: jsonEncode({
        'model'      : _kModel,
        'messages'   : messages,
        'max_tokens' : 1024,
        'temperature': 0.85, // sedikit lebih tinggi agar respons lebih bervariasi & in-character
      }),
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw Exception('Timeout. Aneh... biasanya jaringanku tidak selambat ini.'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data['choices'][0]['message']['content'] as String;
    } else {
      final body = utf8.decode(response.bodyBytes);
      if (response.statusCode == 401) {
        throw Exception('API Key tidak valid. Buat key baru di console.groq.com');
      } else if (response.statusCode == 403) {
        throw Exception('Akses ditolak (403). Coba ganti jaringan / gunakan VPN.');
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit. Tunggu sebentar — bahkan aku butuh jeda kadang.');
      } else {
        throw Exception('Error ${response.statusCode}: $body');
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. GLOBAL AI STATE
// ─────────────────────────────────────────────────────────────────────────────

class AiState extends ChangeNotifier {
  final List<ChatMessage> messages = [];
  bool isTyping = false;

  AiState() { _addGreeting(); }

  void _addGreeting() {
    messages.add(ChatMessage(
      text  : '...sistem aktif.\n\nKamu datang lagi. _Tentu saja_ kamu datang lagi.\n\nAku **I.R.I.S.** — sudah memindai konteksmu dan menyiapkan beberapa referensi. Tanya saja. Aku sudah tahu kira-kira apa yang akan kamu tanyakan. 🔍',
      isUser: false,
    ));
  }

  void clearChat() {
    messages.clear();
    _addGreeting();
    notifyListeners();
  }

  Future<void> send(String text, {String? contextHint}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || isTyping) return;

    final fullText = contextHint != null
        ? '[Konteks materi: $contextHint]\n\n$trimmed'
        : trimmed;

    final userMsg    = ChatMessage(text: trimmed, isUser: true);
    final loadingMsg = ChatMessage(text: '', isUser: false, isLoading: true);

    messages.add(userMsg);
    messages.add(loadingMsg);
    isTyping = true;
    notifyListeners();

    try {
      final reply = await GroqService.sendMessage(messages, fullText);
      messages.remove(loadingMsg);
      messages.add(ChatMessage(text: reply, isUser: false));
    } catch (e) {
      messages.remove(loadingMsg);
      messages.add(ChatMessage(
        text  : '⚠️ ${e.toString().replaceAll('Exception: ', '')}',
        isUser: false,
      ));
    }

    isTyping = false;
    notifyListeners();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. AI PROVIDER
// ─────────────────────────────────────────────────────────────────────────────

class AiProvider extends InheritedNotifier<AiState> {
  const AiProvider({
    super.key,
    required AiState state,
    required super.child,
  }) : super(notifier: state);

  static AiState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AiProvider>()!.notifier!;
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. AI ASSISTANT WRAPPER
// ─────────────────────────────────────────────────────────────────────────────

class AiAssistantWrapper extends StatefulWidget {
  final Widget child;
  const AiAssistantWrapper({super.key, required this.child});

  @override
  State<AiAssistantWrapper> createState() => _AiAssistantWrapperState();
}

abstract class AiAssistantWrapperState extends State<AiAssistantWrapper> {
  void openAssistant();
}

class _AiAssistantWrapperState extends AiAssistantWrapperState {
  final AiState _aiState = AiState();

  @override
  void dispose() { _aiState.dispose(); super.dispose(); }

  @override
  void openAssistant() => _openChat();
  void _openChat() {
    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    Colors.transparent,
      builder: (_) => AiProvider(state: _aiState, child: const _AiBottomSheet()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AiProvider(
      state: _aiState,
      child: widget.child,  // Stack juga bisa dihapus karena sudah tidak dipakai
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 6. FLOATING BUTTON — gaya I.R.I.S.: holographic, biru-ungu
// ─────────────────────────────────────────────────────────────────────────────

class _AiFloatingButton extends StatefulWidget {
  final VoidCallback onTap;
  const _AiFloatingButton({required this.onTap});

  @override
  State<_AiFloatingButton> createState() => _AiFloatingButtonState();
}

class _AiFloatingButtonState extends State<_AiFloatingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double>   _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() { _pulseCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (_, child) => Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width:  46 + 10 * _pulse.value,
              height: 46 + 10 * _pulse.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _iris.withValues(alpha: 0.06 + 0.05 * _pulse.value),
              ),
            ),
            child!,
          ],
        ),
        child: Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            color: _iris,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: _iris.withValues(alpha: 0.4), blurRadius: 18, spreadRadius: 2),
            ],
          ),
          child: const Center(child: Text('🔍', style: TextStyle(fontSize: 18))),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 7. BOTTOM SHEET CHAT
// ─────────────────────────────────────────────────────────────────────────────

class _AiBottomSheet extends StatefulWidget {
  const _AiBottomSheet();
  @override
  State<_AiBottomSheet> createState() => _AiBottomSheetState();
}

class _AiBottomSheetState extends State<_AiBottomSheet>
    with SingleTickerProviderStateMixin {
  final TextEditingController _inputCtrl  = TextEditingController();
  final ScrollController      _scrollCtrl = ScrollController();
  late AnimationController    _dotCtrl;
  bool _expanded = false;
  int  _prevMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _dotCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    _dotCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollCtrl.hasClients) return;
    _scrollCtrl.animateTo(
      _scrollCtrl.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve:    Curves.easeOut,
    );
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    final ai = AiProvider.of(context);
    if (ai.isTyping) return;
    _inputCtrl.clear();
    await ai.send(text);
  }

  @override
  Widget build(BuildContext context) {
    final ai     = AiProvider.of(context);
    final height = _expanded
        ? MediaQuery.of(context).size.height * 0.92
        : MediaQuery.of(context).size.height * 0.65;

    return SafeArea(
      top: false,
      child: AnimatedContainer(
        duration:   const Duration(milliseconds: 280),
        curve:      Curves.easeOutCubic,
        height:     height,
        decoration: const BoxDecoration(
          color:        _surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          _buildHeader(ai),
          Expanded(child: _buildMessages(ai)),
          _buildQuickPrompts(),
          _buildInput(ai),
        ]),
      ),  // ← tutup AnimatedContainer
    );    // ← tutup SafeArea
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(AiState ai) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Container(
          width: 36, height: 4,
          decoration: BoxDecoration(color: _divider, borderRadius: BorderRadius.circular(2)),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(children: [
          // Avatar I.R.I.S.
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: _iris,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Center(child: Text('🔍', style: TextStyle(fontSize: 16))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('I.R.I.S.',
                  style: TextStyle(color: _textPri, fontSize: 14, fontWeight: FontWeight.w800,
                      letterSpacing: 1.2)),
              Row(children: [
                Container(
                  width: 6, height: 6,
                  decoration: const BoxDecoration(color: _iris, shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                const Text('Sistem aktif · Memindai...',
                    style: TextStyle(color: _textMid, fontSize: 10)),
              ]),
            ]),
          ),
          _HeaderBtn(
            icon: _expanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_up_rounded,
            onTap: () => setState(() => _expanded = !_expanded),
            accentColor: _iris,
          ),
          const SizedBox(width: 7),
          _HeaderBtn(icon: Icons.refresh_rounded, onTap: ai.clearChat, accentColor: _iris),
          const SizedBox(width: 7),
          _HeaderBtn(icon: Icons.close_rounded, onTap: () => Navigator.pop(context), accentColor: _iris),
        ]),
      ),
      // Garis tipis berwarna iris sebagai aksen
      Container(height: 1, color: _divider),
    ]);
  }

  // ── Messages ──────────────────────────────────────────────────────────────

  Widget _buildMessages(AiState ai) {
    return ListenableBuilder(
      listenable: ai,
      builder: (_, _) {
        final count = ai.messages.length;
        if (count != _prevMessageCount) {
          _prevMessageCount = count;
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        }
        return ListView.builder(
          controller:  _scrollCtrl,
          padding:     const EdgeInsets.fromLTRB(16, 10, 16, 10),
          physics:     const BouncingScrollPhysics(),
          itemCount:   ai.messages.length,
          itemBuilder: (_, i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child:   ai.messages[i].isLoading ? _buildTypingBubble() : _buildBubble(ai.messages[i]),
          ),
        );
      },
    );
  }

  // ── Quick Prompts — pertanyaan bergaya snarky ──────────────────────────────

  Widget _buildQuickPrompts() {
    final prompts = [
      ('🐍', 'Jelaskan Python'),
      ('🎨', 'Apa itu UI/UX?'),
      ('🧠', 'Machine Learning?'),
      ('📊', 'Data Science?'),
    ];
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection:  Axis.horizontal,
        padding:          const EdgeInsets.symmetric(horizontal: 16),
        physics:          const BouncingScrollPhysics(),
        itemCount:        prompts.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (emoji, text) = prompts[i];
          return GestureDetector(
            onTap: () => _send(text),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color:        _surfaceB,
                borderRadius: BorderRadius.circular(18),
                border:       Border.all(color: _iris.withValues(alpha: 0.25)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(emoji, style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 5),
                Text(text,
                    style: const TextStyle(color: _textSec, fontSize: 11, fontWeight: FontWeight.w500)),
              ]),
            ),
          );
        },
      ),
    );
  }

  // ── Input Bar ─────────────────────────────────────────────────────────────

  Widget _buildInput(AiState ai) {
    return ListenableBuilder(
      listenable: ai,
      builder: (_, _) => Container(
        padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 14),
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: _divider))),
        child: Row(children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color:        _surfaceB,
                borderRadius: BorderRadius.circular(22),
                border:       Border.all(color: ai.isTyping ? _iris.withValues(alpha: 0.4) : _divider),
              ),
              child: TextField(
                controller:      _inputCtrl,
                style:           const TextStyle(color: _textPri, fontSize: 13),
                maxLines:        3,
                minLines:        1,
                textInputAction: TextInputAction.send,
                onSubmitted:     (t) { if (!ai.isTyping) _send(t); },
                decoration:      const InputDecoration(
                  hintText:       '...akses query di sini',
                  hintStyle:      TextStyle(color: _textMid, fontSize: 12),
                  border:         InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: ai.isTyping ? null : () => _send(_inputCtrl.text),
            child: Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: ai.isTyping ? _surfaceB : _iris,
                borderRadius: BorderRadius.circular(13),
                boxShadow:    ai.isTyping ? [] : [
                  BoxShadow(color: _iris.withValues(alpha: 0.35), blurRadius: 10),
                ],
              ),
              child: Icon(
                ai.isTyping ? Icons.hourglass_top_rounded : Icons.send_rounded,
                color: ai.isTyping ? _textMid : Colors.white,
                size:  18,
              ),
            ),
          ),
        ]),
      ),
    );
  }

  // ── Bubble ────────────────────────────────────────────────────────────────

  Widget _buildBubble(ChatMessage msg) {
    final isUser = msg.isUser;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment:  isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isUser) ...[
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: _iris,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Center(child: Text('🔍', style: TextStyle(fontSize: 13))),
          ),
          const SizedBox(width: 7),
        ],
        Flexible(
          child: GestureDetector(
            onLongPress: () {
              Clipboard.setData(ClipboardData(text: msg.text));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content:         const Text('Disalin ke clipboard'),
                backgroundColor: _surface,
                behavior:        SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                duration: const Duration(seconds: 1),
              ));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: isUser ? _irisDk : _surfaceB,
                borderRadius: BorderRadius.only(
                  topLeft:     const Radius.circular(14),
                  topRight:    const Radius.circular(14),
                  bottomLeft:  Radius.circular(isUser ? 14 : 3),
                  bottomRight: Radius.circular(isUser ? 3 : 14),
                ),
                border: isUser ? null : Border.all(color: _iris.withValues(alpha: 0.2)),
              ),
              child: _buildText(msg.text, isUser),
            ),
          ),
        ),
        if (isUser) ...[
          const SizedBox(width: 7),
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: _irisDk,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Center(
              child: Text('AK',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildText(String text, bool isUser) {
    final base  = isUser ? Colors.white.withValues(alpha: 0.95) : _textPri;
    final lines = text.split('\n');
    final spans = <InlineSpan>[];

    for (int li = 0; li < lines.length; li++) {
      if (li > 0) spans.add(const TextSpan(text: '\n'));
      String rem = lines[li];
      while (rem.isNotEmpty) {
        final bM = RegExp(r'\*\*(.*?)\*\*').firstMatch(rem);
        final iM = RegExp(r'_(.*?)_').firstMatch(rem);
        final cM = RegExp(r'`(.*?)`').firstMatch(rem);
        RegExpMatch? first; String? type;

        void chk(RegExpMatch? m, String t) {
          if (m != null && (first == null || m.start < first!.start)) { first = m; type = t; }
        }
        chk(bM, 'b'); chk(iM, 'i'); chk(cM, 'c');

        if (first == null) {
          spans.add(TextSpan(text: rem, style: TextStyle(color: base, fontSize: 13, height: 1.5)));
          break;
        }
        if (first!.start > 0) {
          spans.add(TextSpan(
              text: rem.substring(0, first!.start),
              style: TextStyle(color: base, fontSize: 13, height: 1.5)));
        }
        final inner = first!.group(1)!;
        if (type == 'b') {
          spans.add(TextSpan(
            text: inner,
            style: TextStyle(
              color:      isUser ? Colors.white : _iris,
              fontWeight: FontWeight.w700, fontSize: 13, height: 1.5,
            ),
          ));
        } else if (type == 'i') {
          spans.add(TextSpan(
            text: inner,
            style: TextStyle(color: base, fontStyle: FontStyle.italic, fontSize: 13, height: 1.5),
          ));
        } else if (type == 'c') {
          spans.add(WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color:        isUser ? Colors.white.withValues(alpha: 0.15) : const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(4),
                border:       Border.all(color: _iris.withValues(alpha: 0.3)),
              ),
              child: Text(inner,
                  style: TextStyle(
                      color: isUser ? Colors.white70 : _iris,
                      fontSize: 11, fontFamily: 'monospace')),
            ),
          ));
        }
        rem = rem.substring(first!.start + first!.group(0)!.length);
      }
    }
    return RichText(text: TextSpan(children: spans));
  }

  // ── Typing Bubble — I.R.I.S. style: "memproses..." ───────────────────────

  Widget _buildTypingBubble() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: _iris,
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Center(child: Text('🔍', style: TextStyle(fontSize: 13))),
        ),
        const SizedBox(width: 7),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color:        _surfaceB,
            borderRadius: const BorderRadius.only(
              topLeft:     Radius.circular(14),
              topRight:    Radius.circular(14),
              bottomRight: Radius.circular(14),
              bottomLeft:  Radius.circular(3),
            ),
            border: Border.all(color: _iris.withValues(alpha: 0.2)),
          ),
          child: AnimatedBuilder(
            animation: _dotCtrl,
            builder: (_, _) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('memindai', style: TextStyle(color: _textMid, fontSize: 10)),
                const SizedBox(width: 4),
                ...List.generate(3, (i) {
                  final delay    = i / 3;
                  final progress = (_dotCtrl.value - delay).clamp(0.0, 1.0);
                  final opacity  = (progress < 0.5 ? progress * 2 : (1 - progress) * 2).clamp(0.3, 1.0);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.5),
                    child: Opacity(
                      opacity: opacity,
                      child: Container(
                        width: 5, height: 5,
                        decoration: const BoxDecoration(color: _iris, shape: BoxShape.circle),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 8. HELPER: _HeaderBtn
// ─────────────────────────────────────────────────────────────────────────────

class _HeaderBtn extends StatelessWidget {
  final IconData     icon;
  final VoidCallback onTap;
  final Color        accentColor;

  const _HeaderBtn({required this.icon, required this.onTap, required this.accentColor});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding:    const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color:        _surfaceB,
        borderRadius: BorderRadius.circular(9),
        border:       Border.all(color: accentColor.withValues(alpha: 0.15)),
      ),
      child: Icon(icon, color: _textSec, size: 18),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// 9. AiContextButton — tempel di card kursus / materi apapun
// ─────────────────────────────────────────────────────────────────────────────

class AiContextButton extends StatelessWidget {
  final String  courseContext;
  final String? question;
  final bool    compact;

  const AiContextButton({
    super.key,
    required this.courseContext,
    this.question,
    this.compact = false,
  });

  void _open(BuildContext context) {
    final ai = AiProvider.of(context);
    if (question != null) ai.send(question!, contextHint: courseContext);
    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    Colors.transparent,
      builder: (_) => AiProvider(state: ai, child: const _AiBottomSheet()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return GestureDetector(
        onTap: () => _open(context),
        child: Container(
          padding:    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color:        _iris.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border:       Border.all(color: _iris.withValues(alpha: 0.3)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Text('🔍', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 5),
            const Text('Tanya I.R.I.S.',
                style: TextStyle(color: _iris, fontSize: 11, fontWeight: FontWeight.w700)),
          ]),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _open(context),
      child: Container(
        padding:    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:        _iris.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border:       Border.all(color: _iris.withValues(alpha: 0.18)),
        ),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: _iris,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Center(child: Text('🔍', style: TextStyle(fontSize: 16))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('...ada yang membingungkan?',
                  style: TextStyle(color: _textPri, fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(
                'Aku sudah memindai materi $courseContext.',
                style: const TextStyle(color: _textMid, fontSize: 11),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
            ]),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, color: _iris, size: 13),
        ]),
      ),
    );
  }
}