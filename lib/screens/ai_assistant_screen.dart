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
  final List<Map<String, dynamic>> _messages = [
    {
      'role': 'assistant',
      'content': 'Hello! I am your AI Health Assistant. 🏥\n\nTell me your symptoms, and I will suggest the right specialist and some early precautions.',
      'specialty': null,
    }
  ];

  void _handleSend() {
    if (_controller.text.trim().isEmpty) return;
    final userMessage = _controller.text.trim();
    setState(() {
      _messages.add({'role': 'user', 'content': userMessage, 'specialty': null});
      _controller.clear();
    });

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
        response = "🚨 **Aapko Cardiologist (Dil ke mahir) se mashwara karna chahiye.**\n\n**Ahtiyati Tadabeer:**\n• Sukoon se baith jayein.\n• Tang kapray dheelay kar dein.\n• Zyada harakat na karein.\n• Agar dard zyada hai toh foran Emergency jayein.";
      } else {
        response = "🚨 **Consult a Cardiologist.**\n\n**Precautions:**\n• Sit down and stay calm.\n• Loosen tight clothing.\n• Avoid any physical activity.\n• If pain is severe, go to Emergency.";
      }
      suggestedSpecialty = "Cardiology";
    } else if (q.contains('fever') || q.contains('cold') || q.contains('cough') || q.contains('bukhar') || q.contains('khansi') || q.contains('nazla')) {
      if (isRomanUrdu) {
        response = "👨‍⚕️ **Aapko General Physician se milna chahiye.**\n\n**Ahtiyati Tadabeer:**\n• Zyada se zyada pani piyein.\n• Bukhar check karte rahein.\n• Mukammal aaram karein.";
      } else {
        response = "👨‍⚕️ **Consult a General Physician.**\n\n**Precautions:**\n• Drink plenty of fluids.\n• Monitor your temperature.\n• Take adequate rest.";
      }
      suggestedSpecialty = "General Physician";
    } else if (q.contains('skin') || q.contains('rash') || q.contains('itching') || q.contains('khurish') || q.contains('jild')) {
      if (isRomanUrdu) {
        response = "🧴 **Dermatologist (Jild ke mahir) ko dikhayein.**\n\n**Ahtiyati Tadabeer:**\n• Kharish na karein.\n• Mutasira jagah ko saaf aur khushk rakhein.";
      } else {
        response = "🧴 **Consult a Dermatologist.**\n\n**Precautions:**\n• Avoid scratching.\n• Keep the area clean and dry.";
      }
      suggestedSpecialty = "Dermatology";
    } else if (q.contains('stomach') || q.contains('digestion') || q.contains('vomit') || q.contains('pet') || q.contains('ulte')) {
      if (isRomanUrdu) {
        response = "🤢 **Gastroenterologist (Maiday ke mahir) se rabta karein.**\n\n**Ahtiyati Tadabeer:**\n• Pani aur ORS ka istemal karein.\n• Halki ghiza jaise kaila ya chawal khayein.";
      } else {
        response = "🤢 **Consult a Gastroenterologist.**\n\n**Precautions:**\n• Stay hydrated (ORS is best).\n• Eat light food like bananas or rice.";
      }
      suggestedSpecialty = "Gastroenterology";
    } else if (q.contains('bone') || q.contains('joint') || q.contains('haddi') || q.contains('joro')) {
      if (isRomanUrdu) {
        response = "🦴 **Orthopedic Surgeon (Haddiyo ke mahir) ko dikhayein.**\n\n**Ahtiyati Tadabeer:**\n• Mutasira hissay ko aaram dein.\n• Soojan ke liye baraf ka istemal karein.";
      } else {
        response = "🦴 **Consult an Orthopedic Surgeon.**\n\n**Precautions:**\n• Rest the area.\n• Use ice packs for swelling.";
      }
      suggestedSpecialty = "Orthopedics";
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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
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
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                        ),
                        child: Text(
                          msg['content']!,
                          style: TextStyle(color: isUser ? Colors.white : AppColors.textPrimary, fontSize: 14),
                        ),
                      ),
                      if (!isUser && specialty != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12, left: 4),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              doctorProvider.selectSpecialization(specialty);
                              Navigator.pushNamed(context, AppRoutes.doctorList);
                            },
                            icon: const Icon(Icons.person_search_rounded, size: 18),
                            label: Text(specialty.contains('Cardiology') ? 'Dhundiye Cardiologist' : 'Find $specialty'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Describe symptoms (Fever, Dil me dard)...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _handleSend,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}