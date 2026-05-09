import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'diagnosa_result_screen.dart';

class DiagnosaScreen extends StatefulWidget {
  const DiagnosaScreen({super.key});

  @override
  State<DiagnosaScreen> createState() => _DiagnosaScreenState();
}

class _DiagnosaScreenState extends State<DiagnosaScreen> {
  String? q1;
  String? q2;
  String? q3;
  String? q4;
  String? q5;

  void _submit() {
    if (q1 == null || q2 == null || q3 == null || q4 == null || q5 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap jawab semua pertanyaan'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    bool isPositive = (q1 == 'B' || q1 == 'C' || q2 == 'B' || q3 == 'B' || q4 == 'B' || q5 == 'B');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DiagnosaResultScreen(isPositive: isPositive),
      ),
    );
  }

  Widget _buildRadioOption(String title, String value, String? groupValue, ValueChanged<String?> onChanged) {
    bool isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySurface : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : AppColors.textHint,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestion(String question, List<Map<String, String>> options, String? groupValue, ValueChanged<String?> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          ...options.map((opt) => _buildRadioOption(opt['label']!, opt['value']!, groupValue, onChanged)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Kuesioner Diagnosa',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Langkah 1 dari 1',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '100%',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: 1.0,
              backgroundColor: AppColors.border,
              color: AppColors.primary,
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
            const SizedBox(height: 24),
            const Text(
              'Jawab pertanyaan berikut dengan jujur sesuai dengan kondisi yang Anda rasakan saat ini untuk membantu kami menganalisis gejala Anda.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            _buildQuestion(
              '1. Apakah Anda mengalami batuk saat ini?',
              [
                {'label': 'Tidak', 'value': 'A'},
                {'label': 'Ya, kurang dari 2 minggu', 'value': 'B'},
                {'label': 'Ya, sudah berlangsung selama 2 minggu atau lebih', 'value': 'C'},
              ],
              q1,
              (val) => setState(() => q1 = val),
            ),

            _buildQuestion(
              '2. Apakah Anda mengalami batuk darah (hemoptisis)?',
              [
                {'label': 'Tidak', 'value': 'A'},
                {'label': 'Ya', 'value': 'B'},
              ],
              q2,
              (val) => setState(() => q2 = val),
            ),

            _buildQuestion(
              '3. Apakah Anda mengalami demam?',
              [
                {'label': 'Tidak', 'value': 'A'},
                {'label': 'Ya', 'value': 'B'},
              ],
              q3,
              (val) => setState(() => q3 = val),
            ),

            _buildQuestion(
              '4. Apakah Anda sering berkeringat di malam hari (tanpa melakukan aktivitas fisik)?',
              [
                {'label': 'Tidak', 'value': 'A'},
                {'label': 'Ya', 'value': 'B'},
              ],
              q4,
              (val) => setState(() => q4 = val),
            ),

            _buildQuestion(
              '5. Apakah Anda mengalami penurunan berat badan yang tidak direncanakan?',
              [
                {'label': 'Tidak', 'value': 'A'},
                {'label': 'Ya', 'value': 'B'},
              ],
              q5,
              (val) => setState(() => q5 = val),
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Lanjut',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
