import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leave_application/data/api/leave_api.dart';
import 'package:leave_application/presentation/common/footer.dart';
import 'package:leave_application/presentation/common/alert_utils.dart';
import 'package:dio/dio.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class YearlyPage extends StatefulWidget {
  const YearlyPage({super.key});

  @override
  State<YearlyPage> createState() => _YearlyPageState();
}

class _YearlyPageState extends State<YearlyPage> {
  final LeaveApi _leaveApi = LeaveApi();

  // 디자인 가이드 상수
  final Color primaryColor = const Color(0xFF007AFF);
  final Color inputFillColor = const Color(0xFFE8EFFF);
  final TextStyle titleStyle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Color(0xFF007AFF),
  );

  // 상태 변수
  DateTime _selectedDate = DateTime(DateTime.now().year, 1, 1);
  List<dynamic> _leaveHistory = [];
  String _usedCount = "0";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchYearlyData();
  }

  // 데이터 로드
  Future<void> _fetchYearlyData() async {
    setState(() => _isLoading = true);
    try {
      final dateParam = DateTime(_selectedDate.year, 1, 1);
      final results = await Future.wait([
        _leaveApi.getYearlyLeaveHistory(date: dateParam),
        _leaveApi.getYearlyLeaveUsedCount(date: dateParam),
      ]);

      setState(() {
        _leaveHistory = results[0].data;
        _usedCount = results[1].data.toString();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("데이터 로딩 에러: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteLeaveHistory(String uuid) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final response = await _leaveApi.deleteHistory(
        uuid: uuid,
        userId: "", // 요구사항에 따라 빈값 처리
        code: "",
      );

      if (response.statusCode == 200) {
        // 삭제 성공 시 데이터 다시 불러오기 (리스트 & 개수 갱신)
        await _fetchYearlyData();

        if (!mounted) return;
        AlertUtils.showAlert(context, '삭제 완료되었습니다.');
      }
    } catch (e) {
      String errorMessage = "오류가 발생했습니다. 다시 시도하여 주세요.";
      if (e is DioException && e.response != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      if (!mounted) return;
      AlertUtils.showError(context, errorMessage);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    // 한글 폰트 지원을 위해 필요 (네트워크 폰트 또는 에셋 폰트 사용)
    // 여기서는 Printing 패키지의 기본 한글 지원 폰트를 사용하도록 설정합니다.
    final font = await PdfGoogleFonts.nanumGothicRegular();
    final fontBold = await PdfGoogleFonts.nanumGothicBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '${_selectedDate.year}년 연차 사용 내역서',
                style: pw.TextStyle(font: fontBold, fontSize: 24),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                '총 사용 갯수: $_usedCount 개',
                style: pw.TextStyle(font: font, fontSize: 16),
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 10),

              // 내역 테이블
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  // 헤더
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                          '종류',
                          style: pw.TextStyle(font: fontBold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                          '일자',
                          style: pw.TextStyle(font: fontBold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                          '사유',
                          style: pw.TextStyle(font: fontBold),
                        ),
                      ),
                    ],
                  ),
                  // 데이터 행들
                  ..._leaveHistory.map((item) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            item['leaveTypeName'] ?? '',
                            style: pw.TextStyle(font: font),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            _formatDate(item['date']),
                            style: pw.TextStyle(font: font),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            item['leaveReason'] ?? '',
                            style: pw.TextStyle(font: font),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ],
          );
        },
      ),
    );

    // PDF 미리보기 및 저장/공유 창 띄우기
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: '${_selectedDate.year}_연차내역.pdf',
    );
  }

  // 년도 변경 로직
  void _changeYear(int offset) {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year + offset, 1, 1);
    });
    _fetchYearlyData();
  }

  // 1. 날짜 포맷 변환 함수 (YYYYMMDD -> YYYY년 MM월 DD일)
  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.length < 8) return "-";
    String y = rawDate.substring(0, 4);
    String m = rawDate.substring(4, 6);
    String d = rawDate.substring(6, 8);
    return "$y년 $m월 $d일";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('연도별 연차 내역', style: titleStyle),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        // actions: [
        //   IconButton(
        //     icon: const Icon(
        //       Icons.picture_as_pdf_rounded,
        //       color: Color(0xFF007AFF),
        //       size: 30,
        //     ),
        //     onPressed: _leaveHistory.isEmpty ? null : _generatePdf,
        //   ),
        //   const SizedBox(width: 8),
        // ],
        actions: [
          // 아이콘 대신 텍스트 버튼으로 변경
          TextButton(
            onPressed: _leaveHistory.isEmpty ? null : _generatePdf,
            style: TextButton.styleFrom(
              // 활성화 시 프라이머리 컬러, 비활성화 시 그레이
              foregroundColor: primaryColor,
              disabledForegroundColor: Colors.grey,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text(
              'PDF 저장',
              style: TextStyle(
                fontSize: 14, // 타이틀(18)보다 약간 작게 설정하여 밸런스 유지
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8), // 오른쪽 끝 여백
        ],
      ),
      body: Column(
        children: [
          _buildYearSelector(),
          _buildSummaryCard(),
          const SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildHistoryList(),
          ),
        ],
      ),
      bottomNavigationBar: const CustomFooter(currentIndex: '/yearly'),
    );
  }

  // 년도 선택 UI
  Widget _buildYearSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
            onPressed: () => _changeYear(-1),
            color: primaryColor,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: inputFillColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "${_selectedDate.year}년",
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
            onPressed: () => _changeYear(1),
            color: primaryColor,
          ),
        ],
      ),
    );
  }

  // 요약 카드
  Widget _buildSummaryCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            const Text(
              "사용한 연차",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 5),
            Text(
              "$_usedCount 개",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. 리스트 형태의 내역 UI (배경색 제거, 구분선 추가)
  Widget _buildHistoryList() {
    if (_leaveHistory.isEmpty) {
      return const Center(child: Text("연차 내역이 없습니다."));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      itemCount: _leaveHistory.length,
      separatorBuilder: (context, index) =>
          const Divider(height: 30, thickness: 1, color: Color(0xFFF0F0F0)),
      itemBuilder: (context, index) {
        final item = _leaveHistory[index];
        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildTypeBadge(item['leaveTypeName']),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(item['date']), // 날짜 포맷 적용
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['leaveReason'] ?? "사유 없음",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // 삭제 버튼 (구글 이모티콘 스타일)
            IconButton(
              onPressed: () => _showDeleteConfirm(item['uuid']),
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.redAccent,
                size: 24,
              ),
              constraints: const BoxConstraints(), // 터치 영역 최적화
              padding: EdgeInsets.zero,
            ),
          ],
        );
      },
    );
  }

  Widget _buildTypeBadge(String typeName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: inputFillColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        typeName,
        style: TextStyle(
          color: primaryColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // 삭제 확인 다이얼로그 (ProfilePage 스타일 계승)
  void _showDeleteConfirm(dynamic uuid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "연차 삭제",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("해당연차를 삭제하겠습니까?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("닫기", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteLeaveHistory(uuid); // 삭제 로직 실행
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("삭제", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
