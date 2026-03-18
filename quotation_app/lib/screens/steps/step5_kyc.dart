// ============================================================================
// step5_kyc.dart — Step 5: KYC (Know Your Customer) Document Upload
// ============================================================================
// KYC is a regulatory requirement — the insurer needs to verify the
// policyholder's identity. This step lets the user "upload" documents:
//   - ID Document (front & back)
//   - Proof of Address
//   - Company Registration (for group policies)
//
// NOTE: Since this is a demo/UI-only implementation, the upload buttons
// show a simulated success state. In a real app, you'd use:
//   - file_picker package to select files from the device
//   - image_picker for camera capture
//   - dio or http package to upload to your backend API
//
// FLUTTER CONCEPTS INTRODUCED:
//   - DottedBorder-style container: We create a dashed border effect using
//     a Container with a custom border.
//   - AnimatedSwitcher: Smoothly transitions between two widgets (e.g.,
//     from "Upload" state to "Uploaded ✓" state).
//   - Map<String, bool>: A dictionary/hashmap where keys are document names
//     and values are upload statuses (true = uploaded).
// ============================================================================

import 'package:flutter/material.dart';

class Step5Kyc extends StatefulWidget {
  /// Called when all required documents are submitted
  final VoidCallback onSubmit;

  /// Called when user taps Back
  final VoidCallback onBack;

  const Step5Kyc({
    super.key,
    required this.onSubmit,
    required this.onBack,
  });

  @override
  State<Step5Kyc> createState() => _Step5KycState();
}

class _Step5KycState extends State<Step5Kyc> {
  // ── Document Upload State ──
  // Map tracks which documents have been "uploaded" (simulated).
  // Key = document name, Value = uploaded or not.
  final Map<String, bool> _documents = {
    'ID Document (Front)': false,
    'ID Document (Back)': false,
    'Proof of Address': false,
    'Company Registration': false,
  };

  /// Simulates uploading a document.
  /// In a real app, this would open a file picker and upload to the server.
  void _simulateUpload(String docName) {
    // setState tells Flutter to redraw the screen with the new state
    setState(() {
      _documents[docName] = true;
    });

    // Show a brief success message at the bottom of the screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$docName uploaded successfully'),
        backgroundColor: const Color(0xFF4CAF50), // Green
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// Checks if all REQUIRED documents are uploaded.
  /// Company Registration is optional, so we only check the first 3.
  bool get _allRequiredUploaded {
    return _documents['ID Document (Front)']! &&
        _documents['ID Document (Back)']! &&
        _documents['Proof of Address']!;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Title ──
                  const Text(
                    'KYC Documents',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Upload the required documents to verify your identity. '
                    'Accepted formats: PDF, JPG, PNG (max 5MB each).',
                    style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 24),

                  // ── Document Upload Cards ──
                  // We iterate over each document in the map and build a card
                  ..._documents.entries.map((entry) {
                    final docName = entry.key;
                    final isUploaded = entry.value;
                    final isRequired = docName != 'Company Registration';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildDocumentCard(
                        docName: docName,
                        isUploaded: isUploaded,
                        isRequired: isRequired,
                      ),
                    );
                  }),

                  const SizedBox(height: 8),

                  // ── Upload Progress Indicator ──
                  // Shows how many documents have been uploaded
                  Row(
                    children: [
                      Icon(
                        _allRequiredUploaded
                            ? Icons.check_circle
                            : Icons.info_outline,
                        color: _allRequiredUploaded
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFF3B5BFE),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _allRequiredUploaded
                            ? 'All required documents uploaded'
                            : '${_documents.values.where((v) => v).length} of 3 required documents uploaded',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _allRequiredUploaded
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFF3B5BFE),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Bottom Buttons ──
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onBack,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    // Disable button if required documents aren't uploaded
                    onPressed: _allRequiredUploaded ? widget.onSubmit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B5BFE),
                      foregroundColor: Colors.white,
                      // Disabled state styling
                      disabledBackgroundColor: const Color(0xFFCBD5E1),
                      disabledForegroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Submit Documents'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Builds a single document upload card.
  /// Shows either an upload button or a success state with checkmark.
  Widget _buildDocumentCard({
    required String docName,
    required bool isUploaded,
    required bool isRequired,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUploaded
            ? const Color(0xFFF0FDF4) // Light green when uploaded
            : const Color(0xFFFAFBFD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUploaded
              ? const Color(0xFF86EFAC) // Green border when uploaded
              : const Color(0xFFE2E8F0),
          // Dashed effect is simulated with a solid thin border
        ),
      ),
      child: Row(
        children: [
          // ── Document Icon ──
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isUploaded
                  ? const Color(0xFF4CAF50).withOpacity(0.1)
                  : const Color(0xFF3B5BFE).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isUploaded ? Icons.check_circle : Icons.description_outlined,
              color: isUploaded
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFF3B5BFE),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // ── Document Name & Status ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      docName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    if (isRequired)
                      const Text(' *',
                          style: TextStyle(
                              color: Color(0xFFEF4444),
                              fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  isUploaded ? 'Uploaded successfully' : 'Not uploaded yet',
                  style: TextStyle(
                    fontSize: 12,
                    color: isUploaded
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),

          // ── Upload / Re-upload Button ──
          if (isUploaded)
            // Show a "replace" icon for already-uploaded documents
            IconButton(
              onPressed: () => _simulateUpload(docName),
              icon: const Icon(Icons.refresh, color: Color(0xFF64748B)),
              tooltip: 'Replace document',
            )
          else
            // Show an upload button for documents not yet uploaded
            TextButton.icon(
              onPressed: () => _simulateUpload(docName),
              icon: const Icon(Icons.upload_file, size: 18),
              label: const Text('Upload'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF3B5BFE),
              ),
            ),
        ],
      ),
    );
  }
}
