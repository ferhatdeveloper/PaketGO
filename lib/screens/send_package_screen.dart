import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class SendPackageScreen extends StatefulWidget {
  const SendPackageScreen({super.key});

  @override
  State<SendPackageScreen> createState() => _SendPackageScreenState();
}

class _SendPackageScreenState extends State<SendPackageScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isSubmitted = false;

  final _senderNameController = TextEditingController();
  final _senderAddressController = TextEditingController();
  final _senderPhoneController = TextEditingController();
  final _receiverNameController = TextEditingController();
  final _receiverAddressController = TextEditingController();
  final _receiverPhoneController = TextEditingController();
  final _weightController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _packageSize = 'medium';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paket Gönder'),
      ),
      body: _isSubmitted ? _buildSuccess() : _buildForm(),
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: AppTheme.successColor,
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Gönderi Oluşturuldu!',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Takip numaranız:',
              style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'PGO-2024-004',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Ana Sayfaya Dön'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() => _currentStep++);
          } else {
            _submitPackage();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: Text(_currentStep == 2 ? 'Gönder' : 'Devam'),
                ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Geri'),
                  ),
                ],
              ],
            ),
          );
        },
        steps: [
          Step(
            title: Text('Gönderen Bilgileri',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            content: Column(
              children: [
                _buildTextField(_senderNameController, 'Ad Soyad', Icons.person_rounded),
                const SizedBox(height: 12),
                _buildTextField(_senderAddressController, 'Adres', Icons.location_on_rounded),
                const SizedBox(height: 12),
                _buildTextField(_senderPhoneController, 'Telefon', Icons.phone_rounded),
              ],
            ),
          ),
          Step(
            title: Text('Alıcı Bilgileri',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            content: Column(
              children: [
                _buildTextField(_receiverNameController, 'Ad Soyad', Icons.person_rounded),
                const SizedBox(height: 12),
                _buildTextField(_receiverAddressController, 'Adres', Icons.location_on_rounded),
                const SizedBox(height: 12),
                _buildTextField(_receiverPhoneController, 'Telefon', Icons.phone_rounded),
              ],
            ),
          ),
          Step(
            title: Text('Paket Detayları',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            isActive: _currentStep >= 2,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(_weightController, 'Ağırlık (kg)', Icons.scale_rounded),
                const SizedBox(height: 12),
                _buildTextField(_descriptionController, 'Açıklama', Icons.description_rounded),
                const SizedBox(height: 16),
                Text(
                  'Paket Boyutu',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                _buildSizeSelector(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor, size: 20),
        labelStyle: GoogleFonts.poppins(fontSize: 14),
      ),
    );
  }

  Widget _buildSizeSelector() {
    final sizes = [
      {'key': 'small', 'label': 'Küçük', 'desc': '0-5 kg'},
      {'key': 'medium', 'label': 'Orta', 'desc': '5-15 kg'},
      {'key': 'large', 'label': 'Büyük', 'desc': '15-30 kg'},
    ];

    return Row(
      children: sizes.map((size) {
        final isSelected = _packageSize == size['key'];
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _packageSize = size['key']!),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor.withOpacity(0.08) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    size['label']!,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    size['desc']!,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _submitPackage() {
    setState(() => _isSubmitted = true);
  }
}
