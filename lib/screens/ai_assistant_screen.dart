import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/doctor_provider.dart';
import '../../routes/app_routes.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [
    {
      'role': 'assistant',
      'content': 'Hello! I am your AI Health Assistant. 🏥\n\nTell me your symptoms, and I will suggest the right specialist and some early precautions.',
      'specialty': null,
    }
  ];

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

  void _handleSend() {
    if (_controller.text.trim().isEmpty) return;
    final userMessage = _controller.text.trim();
    setState(() {
      _messages.add({'role': 'user', 'content': userMessage, 'specialty': null});
      _controller.clear();
    });
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 600), () {
      _processAiResponse(userMessage);
    });
  }

  void _processAiResponse(String query) {
    String response = "";
    String? suggestedSpecialty;
    String q = query.toLowerCase();

    bool isRomanUrdu = q.contains('dard') || q.contains('bukhar') || q.contains('khansi') ||
        q.contains('pet') || q.contains('dil') || q.contains('joro') ||
        q.contains('sar') || q.contains('hai') || q.contains('ho') ||
        q.contains('mujhe') || q.contains('raha');

    if (q.contains('heart') || q.contains('chest pain') || q.contains('dil') || q.contains('seene me dard')) {
      if (isRomanUrdu) {
        response = "🚨 **Aapko Cardiologist (Dil ke mahir) se mashwara karna chahiye.**\n\n**Ahtiyati Tadabeer:**\n• Sukoon se baith jayein.\n• Tang kapray dheelay kar dein.\n• Agar dard zyada hai toh foran Emergency jayein.";
      } else {
        response = "🚨 **Consult a Cardiologist.**\n\n**Precautions:**\n• Sit down and stay calm.\n• If pain is severe, go to Emergency.";
      }
      suggestedSpecialty = "Cardiology";
    } else if (q.contains('fever') || q.contains('cold') || q.contains('cough') || q.contains('bukhar') || q.contains('khansi') || q.contains('nazla')) {
      if (isRomanUrdu) {
        response = "👨‍⚕️ **Aapko General Physician se milna chahiye.**\n\n**Ahtiyati Tadabeer:**\n• Zyada pani piyein aur rest karein.";
      } else {
        response = "👨‍⚕️ **Consult a General Physician.**\n\n**Precautions:**\n• Drink plenty of fluids and take rest.";
      }
      suggestedSpecialty = "General Physician";
    } else {
      if (isRomanUrdu) {
        response = "Main aapko **General Physician** ke paas jane ka mashwara deta hoon. Kya aap apni takleef mazeed tafseel se bata sakte hain?";
      } else {
        response = "I suggest starting with a **General Physician**. Can you describe your symptoms in more detail?";
      }
      suggestedSpecialty = "General Physician";
    }

    setState(() {
      _messages.add({'role': 'assistant', 'content': response, 'specialty': suggestedSpecialty});
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final doctorProvider = Provider.of<DoctorProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AI Health Agent'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      // FIX: Scaffold resizes itself by default, so we don't need to add manual padding
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg['role'] == 'user';
                  final specialty = msg['specialty'];

                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Container(
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isUser ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            msg['content']!,
                            style: TextStyle(color: isUser ? Colors.white : AppColors.textPrimary),
                          ),
                        ),
                        if (!isUser && specialty != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ElevatedButton(
                              onPressed: () {
                                doctorProvider.selectSpecialization(specialty);
                                Navigator.pushNamed(context, AppRoutes.doctorList);
                              },
                              child: Text('Find $specialty'),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Input Area
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Describe symptoms...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.send, color: AppColors.primary),
                    onPressed: _handleSend,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}