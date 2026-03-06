import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import '../models/api_response.dart';
import '../services/api_service.dart';
import '../services/chat_history_service.dart';
import '../services/auth_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:convert';

class SessionData {
  final String id;
  final String sessionId;
  List<ChatMessage> messages;
  final String language;
  final DateTime createdAt;

  SessionData({
    required this.id,
    required this.sessionId,
    required this.messages,
    required this.language,
    required this.createdAt,
  });

  String getTitle() {
    if (messages.isEmpty) return 'New Session';
    final firstMsg = messages.firstWhere((m) => m.isUser, orElse: () => ChatMessage(text: 'New Session', isUser: false));
    return firstMsg.text.length > 40 ? '${firstMsg.text.substring(0, 40)}...' : firstMsg.text;
  }

  int get messageCount => messages.length;
}

class ChatWithSidebarScreen extends StatefulWidget {
  const ChatWithSidebarScreen({Key? key}) : super(key: key);

  @override
  State<ChatWithSidebarScreen> createState() => _ChatWithSidebarScreenState();
}

class _ChatWithSidebarScreenState extends State<ChatWithSidebarScreen> {
  late TextEditingController _messageController;
  late FocusNode _focusNode;
  late ScrollController _scrollController;
  
  // MONGODB SESSIONS
  Map<String, SessionData> sessions = {};
  String? activeSessionId;
  String selectedLanguage = 'python';
  bool isLoading = false;
  bool isLoadingSessions = true;
  bool sidebarOpen = true;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _focusNode = FocusNode();
    _scrollController = ScrollController();
    _loadSessionsFromMongoDB();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadSessionsFromMongoDB() async {
    print('Loading sessions from MongoDB...');
    try {
      final result = await chatHistoryService.getHistory(page: 1, limit: 100);
      if (result['success'] == true && mounted) {
        final items = List<Map<String, dynamic>>.from(result['items'] ?? []);
        
        // GROUP BY SESSION_ID
        Map<String, List<Map<String, dynamic>>> groupedBySession = {};
        
        for (var item in items) {
          final sessionId = item['session_id']?.toString() ?? item['_id']?.toString() ?? '';
          if (!groupedBySession.containsKey(sessionId)) {
            groupedBySession[sessionId] = [];
          }
          groupedBySession[sessionId]!.add(item);
        }

        // CREATE SESSION DATA FROM GROUPED ITEMS
        Map<String, SessionData> newSessions = {};
        for (var sessionId in groupedBySession.keys) {
          final sessionItems = groupedBySession[sessionId]!;
          final messages = <ChatMessage>[];
          DateTime createdAt = DateTime.now();
          String language = 'python';

          // BUILD MESSAGES FROM ALL ITEMS IN SESSION
          for (var item in sessionItems) {
            language = item['language'] ?? 'python';
            final timestamp = item['timestamp'];
            if (timestamp != null) {
              try {
                createdAt = DateTime.parse(timestamp);
              } catch (e) {}
            }

            final userMsg = item['user_prompt']?.toString() ?? '';
            final aiMsg = item['ai_response']?.toString() ?? '';
            final codeMsg = item['fixed_code']?.toString() ?? '';
            final tipsList = item['tips'] is List ? List<String>.from(item['tips']) : <String>[];

            if (userMsg.isNotEmpty) {
              messages.add(ChatMessage.user(userMsg));
            }

            if (aiMsg.isNotEmpty) {
              messages.add(ChatMessage(
                text: aiMsg,
                isUser: false,
                code: codeMsg.isNotEmpty ? codeMsg : null,
                tips: tipsList.isNotEmpty ? tipsList : null,
              ));
            }
          }

          newSessions[sessionId] = SessionData(
            id: sessionId,
            sessionId: sessionId,
            messages: messages,
            language: language,
            createdAt: createdAt,
          );
        }

        setState(() {
          sessions = newSessions;
          isLoadingSessions = false;
        });
        
        print('Loaded ${sessions.length} sessions from MongoDB');
      }
    } catch (e) {
      print('Error loading sessions: $e');
      if (mounted) setState(() => isLoadingSessions = false);
    }
  }

  void _createNewSession() {
    final newSessionId = DateTime.now().millisecondsSinceEpoch.toString();
    setState(() {
      sessions[newSessionId] = SessionData(
        id: newSessionId,
        sessionId: newSessionId,
        messages: [],
        language: selectedLanguage,
        createdAt: DateTime.now(),
      );
      activeSessionId = newSessionId;
    });
    _focusNode.requestFocus();
    print('Created new session: $newSessionId');
  }

  void _deleteSession(String sessionId) {
    setState(() {
      sessions.remove(sessionId);
      if (activeSessionId == sessionId) {
        activeSessionId = null;
      }
    });
    print('Deleted session: $sessionId');
  }

Future<void> _selectSession(String sessionId) async {
  setState(() {
    activeSessionId = sessionId;
    isLoading = true;
  });

  try {
    final result = await chatHistoryService.getSessionMessages(sessionId);

    if (result['success'] == true) {
      final msgs = List<Map<String, dynamic>>.from(result['messages']);

      final messages = <ChatMessage>[];

      for (var m in msgs) {
        if ((m['user_prompt'] ?? '').isNotEmpty) {
          messages.add(ChatMessage.user(m['user_prompt']));
        }

        if ((m['ai_response'] ?? '').isNotEmpty) {
          messages.add(ChatMessage(
            text: m['ai_response'],
            isUser: false,
            code: m['fixed_code'],
            tips: (m['tips'] as List?)?.cast<String>(),
          ));
        }
      }

      setState(() {
        sessions[sessionId]!.messages = messages;
        selectedLanguage = sessions[sessionId]?.language ?? 'python';
        isLoading = false;
      });
    }
  } catch (e) {
    print("Session load error: $e");
    setState(() => isLoading = false);
  }

  _scrollToBottom();
  _focusNode.requestFocus();

  print('Selected session: $sessionId with ${sessions[sessionId]?.messageCount} messages');
}

  Future<void> _sendMessage(String userMessage) async {
    if (userMessage.isEmpty || isLoading) return;

    // CREATE SESSION IF NONE EXISTS
    if (activeSessionId == null || !sessions.containsKey(activeSessionId)) {
      _createNewSession();
    }

    final sessionId = activeSessionId!;

    setState(() {
      sessions[sessionId]!.messages.add(ChatMessage.user(userMessage));
      isLoading = true;
    });

    _scrollToBottom();
    _messageController.clear();

    try {
      final token = await authService.getToken();
      if (token == null) {
        setState(() {
          sessions[sessionId]!.messages.add(ChatMessage(text: 'Not authenticated', isUser: false));
          isLoading = false;
        });
        return;
      }

      print('Sending message in session: $sessionId');
      final response = await ApiService.sendChatMessage(
        message: userMessage,
        language: selectedLanguage,
        sessionId:sessionId,
      );

      print('Got response, adding to session');
      setState(() {
        sessions[sessionId]!.messages.add(ChatMessage.fromResponse(response));
        isLoading = false;
      });

      // SAVE TO MONGODB WITH SESSION_ID
      print('Saving to MongoDB with session_id: $sessionId');
      await chatHistoryService.saveChat(
        sessionId: sessionId,
        userPrompt: userMessage,
        aiResponse: response.solution,
        language: selectedLanguage,
        responseType: 'generation',
        fixedCode: response.fixedCode,
        tips: response.tips,
      );
      _scrollToBottom();
      _focusNode.requestFocus();
    } catch (e) {
      print('Error: $e');
      setState(() {
        sessions[sessionId]!.messages.add(ChatMessage(text: 'Error: $e', isUser: false));
        isLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  List<SessionData> get sortedSessions {
    final list = sessions.values.toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  SessionData? get activeSession => activeSessionId != null ? sessions[activeSessionId] : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryDark,
      body: Row(
        children: [
          // SIDEBAR
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: sidebarOpen ? 260 : 0,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: AppConstants.accentGreen.withOpacity(0.2))),
              color: AppConstants.primaryDark,
            ),
            child: sidebarOpen ? _buildSidebar() : const SizedBox(),
          ),
          // MAIN AREA
          Expanded(
            child: Column(
              children: [
                // HEADER
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppConstants.accentGreen.withOpacity(0.2))),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(sidebarOpen ? Icons.menu_open : Icons.menu, color: AppConstants.accentGreen, size: 20),
                        onPressed: () => setState(() => sidebarOpen = !sidebarOpen),
                        padding: const EdgeInsets.all(0),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          activeSession?.getTitle() ?? 'CodeHax Sessions',
                          style: GoogleFonts.robotoMono(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.accentGreen,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 20),
                        color: AppConstants.accentGreen,
                        onPressed: _createNewSession,
                        padding: const EdgeInsets.all(0),
                      ),
                    ],
                  ),
                ),
                // MESSAGES
                Expanded(
                  child: activeSession == null
                      ? Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppConstants.accentGreen.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Hello! Start a new session or click one below!',
                              style: GoogleFonts.robotoMono(
                                color: AppConstants.accentGreen,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        )
                      : activeSession!.messages.isEmpty
                          ? Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppConstants.accentGreen.withOpacity(0.3)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'New session in ${selectedLanguage}. Ask me anything!',
                                  style: GoogleFonts.robotoMono(
                                    color: AppConstants.accentGreen,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(20),
                              itemCount: activeSession!.messages.length + (isLoading ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == activeSession!.messages.length) {
                                  return _buildTypingIndicator();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _buildChatBubble(activeSession!.messages[index]),
                                );
                              },
                            ),
                ),
                // INPUT
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: AppConstants.accentGreen.withOpacity(0.2))),
                  ),
                  child: Column(
                    children: [
                      // LANGUAGE SELECTOR
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ['python', 'javascript', 'java', 'cpp', 'rust', 'go'].map((lang) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(lang),
                                selected: selectedLanguage == lang,
                                onSelected: (_) => setState(() => selectedLanguage = lang),
                                backgroundColor: selectedLanguage == lang ? AppConstants.accentGreen.withOpacity(0.2) : Colors.transparent,
                                side: BorderSide(
                                  color: selectedLanguage == lang ? AppConstants.accentGreen : AppConstants.accentGreen.withOpacity(0.3),
                                ),
                                labelStyle: GoogleFonts.robotoMono(
                                  fontSize: 11,
                                  color: selectedLanguage == lang ? AppConstants.accentGreen : AppConstants.accentGreen.withOpacity(0.6),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // INPUT FIELD
                      Row(
                        children: [
                          Expanded(
                            child: Focus(
                                focusNode: _focusNode,

                                onKeyEvent: (node, event) {
                                  if (event is KeyDownEvent) {

                                    // ENTER pressed
                                    if (event.logicalKey == LogicalKeyboardKey.enter) {

                                      // SHIFT + ENTER → new line
                                      if (HardwareKeyboard.instance.isShiftPressed) {
                                        return KeyEventResult.ignored;
                                      }

                                      // ENTER → send
                                      if (!isLoading && _messageController.text.trim().isNotEmpty) {
                                        _sendMessage(_messageController.text.trim());
                                        return KeyEventResult.handled;
                                      }
                                    }
                                  }

                                  return KeyEventResult.ignored;
                                },

                                child: TextField(
                                  controller: _messageController,
                                  style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 13),

                                  keyboardType: TextInputType.multiline,
                                  textInputAction: TextInputAction.newline,

                                  maxLines: null,
                                  minLines: 1,

                                  decoration: InputDecoration(
                                    hintText: 'Ask me... (Enter = send, Shift+Enter = new line)',
                                    hintStyle: GoogleFonts.robotoMono(color: Colors.white24, fontSize: 12),
                                    filled: true,
                                    fillColor: AppConstants.secondaryDark,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              )
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: isLoading ? null : () => _sendMessage(_messageController.text),
                            child: Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: isLoading ? AppConstants.accentGreen.withOpacity(0.3) : AppConstants.accentGreen,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Icon(
                                Icons.play_arrow,
                                color: isLoading ? AppConstants.accentGreen : Colors.black,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      color: AppConstants.primaryDark,
      child: Column(
        children: [
          // NEW SESSION BUTTON
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton.icon(
              onPressed: _createNewSession,
              icon: const Icon(Icons.edit, size: 14),
              label: const Text('New Session'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.accentGreen,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 40),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          // SESSIONS LABEL
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Neural Vault',
                style: GoogleFonts.robotoMono(
                  fontSize: 10,
                  color: AppConstants.accentGreen.withOpacity(0.5),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // SESSIONS LIST
          Expanded(
            child: isLoadingSessions
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(AppConstants.accentGreen),
                    ),
                  )
                : sortedSessions.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            'No sessions yet',
                            style: GoogleFonts.robotoMono(
                              fontSize: 11,
                              color: AppConstants.accentGreen.withOpacity(0.3),
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: sortedSessions.length,
                        itemBuilder: (context, index) {
                          final session = sortedSessions[index];
                          final isActive = activeSessionId == session.sessionId;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isActive ? AppConstants.accentGreen.withOpacity(0.5) : Colors.transparent,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: isActive ? AppConstants.accentGreen.withOpacity(0.1) : Colors.transparent,
                            ),
                            child: ListTile(
                              onTap: () => _selectSession(session.sessionId),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              title: Text(
                                session.getTitle(),
                                style: GoogleFonts.robotoMono(
                                  fontSize: 11,
                                  color: isActive ? AppConstants.accentGreen : AppConstants.accentGreen.withOpacity(0.7),
                                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '${session.language} · ${session.messageCount} msg${session.messageCount != 1 ? 's' : ''}',
                                style: GoogleFonts.robotoMono(
                                  fontSize: 9,
                                  color: AppConstants.accentGreen.withOpacity(0.4),
                                ),
                              ),
                              trailing: GestureDetector(
                                onTap: () => _deleteSession(session.sessionId),
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: AppConstants.accentGreen.withOpacity(0.4),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(12),
            
            decoration: BoxDecoration(
              color: message.isUser ? AppConstants.accentGreen.withOpacity(0.2) : AppConstants.secondaryDark,
              border: Border.all(
                color: message.isUser ? AppConstants.accentGreen.withOpacity(0.5) : AppConstants.accentCyan.withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: MarkdownBody(
              data: message.text,
              styleSheet: MarkdownStyleSheet(
                p: GoogleFonts.robotoMono(color: Colors.white, fontSize: 13),
                strong: GoogleFonts.robotoMono(
                  color: AppConstants.accentGreen,
                  fontWeight: FontWeight.bold,
                ),
                code: GoogleFonts.robotoMono(
                  color: AppConstants.accentLime,
                  fontSize: 12,
                ),
                tableHead: GoogleFonts.robotoMono(
                  color: AppConstants.accentGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (message.code != null && message.code!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxWidth: 700),
              decoration: BoxDecoration(
                border: Border.all(color: AppConstants.accentLime),
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFF0d1117),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppConstants.accentLime)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'code',
                          style: GoogleFonts.robotoMono(color: AppConstants.accentLime, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: message.code!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Copied!'), duration: Duration(seconds: 1)),
                            );
                          },
                          child: Icon(Icons.copy, size: 14, color: AppConstants.accentLime),
                        ),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        message.code!,
                        style: GoogleFonts.robotoMono(color: AppConstants.accentLime, fontSize: 9, height: 1.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppConstants.accentGreen.withOpacity(0.3), AppConstants.accentGreen.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Center(
              child: Text(
                '</>',
                style: GoogleFonts.robotoMono(
                  color: AppConstants.accentGreen,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppConstants.accentGreen.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: List.generate(
                3,
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: AppConstants.accentGreen,
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
