import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert' show base64Encode;
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import '../../data/models/financial_report_model.dart';
import '../../data/repositories/report_repository.dart';
import '../../data/services/supabase_service.dart';
import '../../data/services/local_storage_service.dart';
import '../../data/services/export_service.dart';
import '../../utils/constants.dart';

class ExportReportPage extends StatefulWidget {
  final LocalStorageService localStorage;

  const ExportReportPage({
    super.key,
    required this.localStorage,
  });

  @override
  State<ExportReportPage> createState() => _ExportReportPageState();
}

class _ExportReportPageState extends State<ExportReportPage> {
  late ReportRepository _reportRepository;
  late ExportService _exportService;

  // UI State
  String _selectedFormat = 'pdf'; // 'pdf' or 'excel'
  String _selectedPeriod = 'monthly'; // 'monthly', 'previous_month', 'yearly', 'previous_year', 'all_time', 'custom'
  String _selectedExportType = 'download'; // 'download' or 'email'

  DateTime _customStartDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _customEndDate = DateTime.now();

  bool _isLoading = false;
  FinancialReportData? _previewData;

  @override
  void initState() {
    super.initState();
    _reportRepository = ReportRepository(
      supabaseService: SupabaseService.instance,
    );
    _exportService = ExportService.instance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Laporan Keuangan'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Format Selection
              _buildSectionHeader('Format Export'),
              _buildFormatSelector(),
              const SizedBox(height: 24),

              // Period Selection
              _buildSectionHeader('Pilih Periode'),
              _buildPeriodSelector(),

              // Custom date picker
              if (_selectedPeriod == 'custom') ...[
                const SizedBox(height: 16),
                _buildCustomDatePicker(),
              ],
              const SizedBox(height: 24),

              // Export Type Selection
              _buildSectionHeader('Metode Export'),
              _buildExportTypeSelector(),
              const SizedBox(height: 24),

              // Preview Section
              if (_previewData != null) ...[
                _buildSectionHeader('Pratinjau Laporan'),
                _buildPreviewSection(),
                const SizedBox(height: 24),
              ],

              // Action Buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.text,
      ),
    );
  }

  Widget _buildFormatSelector() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildFormatCard(
                'PDF',
                'pdf',
                Icons.picture_as_pdf_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFormatCard(
                'Excel',
                'excel',
                Icons.table_chart_outlined,
                isDisabled: kIsWeb,
              ),
            ),
          ],
        ),
        if (kIsWeb) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Export ke Excel tidak didukung di web. Gunakan aplikasi mobile/desktop untuk Excel.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber[900],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFormatCard(
    String label,
    String value,
    IconData icon, {
    bool isDisabled = false,
  }) {
    final isSelected = _selectedFormat == value && !isDisabled;
    return GestureDetector(
      onTap: isDisabled
          ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Export ke Excel tidak didukung di platform web. Gunakan PDF atau akses dari aplikasi mobile/desktop.',
                  ),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          : () => setState(() => _selectedFormat = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : isDisabled
                  ? Colors.grey[100]
                  : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : isDisabled
                    ? Colors.grey[300]!
                    : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Column(
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : AppColors.text,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.text,
                  ),
                ),
              ],
            ),
            if (isDisabled)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'N/A Web',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final periods = [
      ('Bulan Ini', 'monthly'),
      ('Bulan Lalu', 'previous_month'),
      ('Tahun Ini', 'yearly'),
      ('Tahun Lalu', 'previous_year'),
      ('Semua Data', 'all_time'),
      ('Kustom', 'custom'),
    ];

    return Column(
      children: periods.map((period) {
        final label = period.$1;
        final value = period.$2;
        final isSelected = _selectedPeriod == value;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () => setState(() => _selectedPeriod = value),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withAlpha(25) : Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.grey[400]!,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Center(
                            child: Icon(
                              Icons.check,
                              size: 12,
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: AppColors.text,
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

  Widget _buildCustomDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDatePickerButton(
                'Dari Tanggal',
                _customStartDate,
                (date) => setState(() => _customStartDate = date),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDatePickerButton(
                'Sampai Tanggal',
                _customEndDate,
                (date) => setState(() => _customEndDate = date),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDatePickerButton(
    String label,
    DateTime selectedDate,
    Function(DateTime) onDateSelected,
  ) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildExportTypeCard(
            'Download',
            'download',
            Icons.download_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildExportTypeCard(
            'Share',
            'email',
            Icons.share_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildExportTypeCard(String label, String value, IconData icon) {
    final isSelected = _selectedExportType == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedExportType = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.text,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSection() {
    if (_previewData == null) return const SizedBox.shrink();

    final data = _previewData!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Periode: ${_formatDateRange(data.startDate, data.endDate)}',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPreviewStat('Pemasukan', data.totalIncome, Colors.green),
              _buildPreviewStat('Pengeluaran', data.totalExpense, Colors.orange),
              _buildPreviewStat(
                'Saldo',
                data.netBalance,
                data.netBalance >= 0 ? Colors.green : Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Total Transaksi: ${data.transactions.length}',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewStat(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Rp ${value.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _onPreviewPressed,
            icon: const Icon(Icons.preview_outlined),
            label: const Text('Pratinjau'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.grey[400],
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _onExportPressed,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(_selectedExportType == 'download'
                    ? Icons.download_outlined
                    : Icons.share_outlined),
            label: Text(_isLoading
                ? 'Sedang Memproses...'
                : _selectedExportType == 'download'
                    ? 'Download ${_selectedFormat.toUpperCase()}'
                    : 'Share ${_selectedFormat.toUpperCase()}'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onPreviewPressed() async {
    try {
      setState(() => _isLoading = true);

      final startDate = _getStartDate();
      final endDate = _getEndDate();

      final reportData = await _reportRepository.getFinancialReport(
        startDate: startDate,
        endDate: endDate,
        reportType: _selectedPeriod,
      );

      setState(() {
        _previewData = reportData;
        _isLoading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pratinjau dimuat')),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Gagal memuat pratinjau: $e');
    }
  }

  Future<void> _onExportPressed() async {
    try {
      setState(() => _isLoading = true);

      // Check if Excel is selected on web
      if (kIsWeb && _selectedFormat == 'excel') {
        setState(() => _isLoading = false);
        _showError('Export ke Excel tidak didukung di web. Silakan gunakan PDF atau akses dari aplikasi mobile/desktop.');
        return;
      }

      if (_previewData == null) {
        _showError('Silakan pratinjau terlebih dahulu');
        setState(() => _isLoading = false);
        return;
      }

      final username = await SupabaseService.instance.getUsername();
      final userEmail = SupabaseService.instance.user?.email ?? 'unknown@email.com';

      // Generate report bytes
      Uint8List reportBytes;
      String fileExtension;

      if (_selectedFormat == 'pdf') {
        reportBytes = await _exportService.generatePDF(
          _previewData!,
          username,
          userEmail,
        );
        fileExtension = 'pdf';
      } else {
        reportBytes = await _exportService.generateExcel(
          _previewData!,
          username,
          userEmail,
        );
        fileExtension = 'xlsx';
      }

      // Save and share file
      final fileName =
          'Laporan_Keuangan_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      if (kIsWeb) {
        // Web: Trigger browser download
        _triggerWebDownload(reportBytes, fileName);
        setState(() => _isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF berhasil diunduh!'),
          ),
        );
      } else {
        // Mobile/Desktop: Save to file system and share
        late Directory directory;
        try {
          directory = await getApplicationDocumentsDirectory();
        } catch (e) {
          directory = Directory.systemTemp;
        }

        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(reportBytes);

        setState(() => _isLoading = false);

        // Share the file
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Laporan Keuangan SpendSense',
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _selectedExportType == 'download'
                  ? 'File berhasil dipersiapkan untuk download'
                  : 'File siap untuk dibagikan',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Gagal export file: $e');
    }
  }

  void _triggerWebDownload(Uint8List bytes, String fileName) {
    // Create blob from bytes
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    
    // Create a temporary anchor element and trigger download
    final anchor = html.AnchorElement(href: url);
    anchor.download = fileName;
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    
    // Clean up the URL
    html.Url.revokeObjectUrl(url);
  }

  DateTime _getStartDate() {
    switch (_selectedPeriod) {
      case 'monthly':
        final now = DateTime.now();
        return DateTime(now.year, now.month, 1);
      case 'previous_month':
        final now = DateTime.now();
        final prev = DateTime(now.year, now.month - 1, 1);
        return prev;
      case 'yearly':
        return DateTime(DateTime.now().year, 1, 1);
      case 'previous_year':
        return DateTime(DateTime.now().year - 1, 1, 1);
      case 'custom':
        return _customStartDate;
      default:
        return _customStartDate;
    }
  }

  DateTime _getEndDate() {
    switch (_selectedPeriod) {
      case 'monthly':
        final now = DateTime.now();
        return DateTime(now.year, now.month + 1, 0);
      case 'previous_month':
        final now = DateTime.now();
        final prev = DateTime(now.year, now.month - 1);
        return DateTime(prev.year, prev.month + 1, 0);
      case 'yearly':
        return DateTime(DateTime.now().year, 12, 31);
      case 'previous_year':
        return DateTime(DateTime.now().year - 1, 12, 31);
      case 'custom':
        return _customEndDate;
      default:
        return _customEndDate;
    }
  }

  String _formatDateRange(DateTime start, DateTime end) {
    return '${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
