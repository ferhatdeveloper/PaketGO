import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  final String courierName;
  const ChatScreen({super.key, this.courierName = 'Emre Aydın'});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [
    _ChatMessage(text: 'Merhaba! Siparişinizi teslim almak üzere yoldayım.', isMe: false, time: '14:30'),
    _ChatMessage(text: 'Tahmini 5 dakika içinde orada olacağım.', isMe: false, time: '14:30'),
    _ChatMessage(text: 'Tamam, teşekkürler! Bekliyorum.', isMe: true, time: '14:31'),
    _ChatMessage(text: 'Kapı zili çalışmıyor, lütfen gelince arayın.', isMe: true, time: '14:32'),
    _ChatMessage(text: 'Anlaşıldı, arayacağım 👍', isMe: false, time: '14:32'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.12),
            child: Text(widget.courierName[0], style: GoogleFonts.poppins(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.courierName, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
            Text('Çevrimiçi', style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.successColor)),
          ]),
        ]),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.phone_rounded, color: AppTheme.primaryColor)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _buildMessage(_messages[i]),
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessage(_ChatMessage msg) {
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: msg.isMe ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.isMe ? 16 : 4),
            bottomRight: Radius.circular(msg.isMe ? 4 : 16),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(msg.text, style: GoogleFonts.poppins(fontSize: 14, color: msg.isMe ? Colors.white : AppTheme.textPrimary)),
            const SizedBox(height: 4),
            Text(msg.time, style: GoogleFonts.poppins(fontSize: 10, color: msg.isMe ? Colors.white70 : AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))]),
      child: SafeArea(
        child: Row(children: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.attach_file_rounded, color: AppTheme.textSecondary)),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Mesaj yazın...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
                filled: true,
                fillColor: AppTheme.backgroundColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 44, height: 44,
              decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ]),
      ),
    );
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text: _controller.text, isMe: true, time: '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}'));
      _controller.clear();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    });
  }
}

class _ChatMessage {
  final String text;
  final bool isMe;
  final String time;

  _ChatMessage({required this.text, required this.isMe, required this.time});
}
