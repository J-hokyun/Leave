import 'package:flutter/material.dart';
import 'package:leave_application/core/colors/app_colors_extension.dart';
import 'package:leave_application/core/typography/app_text_theme_extension.dart';
import 'package:leave_application/presentation/common/footer.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:leave_application/data/api/leave_api.dart';
import 'package:leave_application/presentation/common/alert_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

var logger = Logger(
  printer: PrettyPrinter(), // 로그를 보기 좋게 박스 형태로 출력해줌
);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LeaveApi _leaveApi = LeaveApi();
  late DateTime _selectedDay;

  bool _isLoading = false;
  bool _isInitialLoading = true;

  /* 사용내역 조회 관련 변수  */
  String historyDate = "";
  String historyreason = "";
  String historyId = "";
  String hasPrev = "";
  String hasNext = "";

  /* 연차 사용내역 저장 관련 변수  */
  String _selectedType = '연차'; // 연차, 반차, 반반차
  String usedDays = "";
  String remainedDays = "";

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  final TextEditingController _reasonController = TextEditingController();

  Future<void> _handleSave() async {
    if (_isLoading) return;

    // 요구사항: 타입 매핑 (연차:0, 반차:1, 반반차:2)
    int typeValue;
    switch (_selectedType) {
      case '연차':
        typeValue = 0;
        break;
      case '반차':
        typeValue = 1;
        break;
      case '반반차':
        typeValue = 2;
        break;
      default:
        typeValue = 0;
    }

    // 요구사항: 날짜 포맷 (yyyyMMdd)
    String startStr = DateFormat('yyyyMMdd').format(_startDate);
    String endStr = DateFormat('yyyyMMdd').format(_endDate);

    setState(() => _isLoading = true);

    try {
      final response = await _leaveApi.saveLeaveHistory(
        type: typeValue,
        start: startStr,
        end: endStr,
        reason: _reasonController.text,
      );

      if (mounted &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        AlertUtils.showAlert(context, "저장에 성공하였습니다.");
        _reasonController.clear();
        await _fetchLeaveCounts();
        await _fetchCurrentUsedHistory();
      }
    } catch (e) {
      String errorMessage = "오류가 발생했습니다. 다시 시도하여 주세요.";

      if (e is DioException && e.response != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      } else {
        errorMessage = e.toString();
      }

      logger.d("연차 저장 실패 : $errorMessage");
      if (!mounted) return;
      AlertUtils.showError(context, errorMessage);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchCurrentUsedHistory() async {
    try {
      final response = await _leaveApi.getCurrentUsed(
        uuid: "",
        userId: "",
        date: "",
      );

      if (response.statusCode == 200) {
        setState(() {
          historyId = (response.data['uuid'] ?? "").toString();
          historyDate = (response.data['date'] ?? "").toString();
          historyreason = (response.data['reason'] ?? "").toString();
          hasNext = (response.data['hasNext'] ?? "false").toString();
          hasPrev = (response.data['hasPrev'] ?? "false").toString();
          _isInitialLoading = false;
        });
      }
    } catch (e) {
      logger.e("초기 데이터 로딩 실패: $e");
      setState(() => _isInitialLoading = false);
    }
  }

  Future<void> _fetchNextUsedHistory() async {
    try {
      final response = await _leaveApi.getNextUsed(
        uuid: historyId,
        userId: "",
        date: historyDate,
      );

      if (response.statusCode == 200) {
        // 서버 DTO 필드명(usedLeave, remainedLeave)에 맞춰서 매핑
        setState(() {
          historyId = (response.data['uuid'] ?? "").toString();
          historyDate = (response.data['date'] ?? "").toString();
          historyreason = (response.data['reason'] ?? "").toString();
          hasNext = (response.data['hasNext'] ?? "false").toString();
          hasPrev = (response.data['hasPrev'] ?? "false").toString();
          _isInitialLoading = false;
        });
      }
    } catch (e) {
      logger.e("초기 데이터 로딩 실패: $e");
      setState(() => _isInitialLoading = false);
    }
  }

  Future<void> _fetchPrevUsedHistory() async {
    try {
      final response = await _leaveApi.getPrevUsed(
        uuid: historyId,
        userId: "",
        date: historyDate,
      );

      if (response.statusCode == 200) {
        setState(() {
          historyId = (response.data['uuid'] ?? "").toString();
          historyDate = (response.data['date'] ?? "").toString();
          historyreason = (response.data['reason'] ?? "").toString();
          hasNext = (response.data['hasNext'] ?? "false").toString();
          hasPrev = (response.data['hasPrev'] ?? "false").toString();
          _isInitialLoading = false;
        });
      }
    } catch (e) {
      logger.e("초기 데이터 로딩 실패: $e");
      setState(() => _isInitialLoading = false);
    }
  }

  Future<void> _fetchLeaveCounts() async {
    try {
      final response = await _leaveApi.getLeaveCounts();

      if (response.statusCode == 200) {
        setState(() {
          usedDays = response.data['used'].toString();
          remainedDays = response.data['remained'].toString();
          _isInitialLoading = false;
        });
      }
    } catch (e) {
      logger.e("초기 데이터 로딩 실패: $e");
      setState(() => _isInitialLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _fetchLeaveCounts();
    _fetchCurrentUsedHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 헤더 섹션
              // _buildHeader(),
              const SizedBox(height: 24),
              // 나의 정보 섹션
              _buildMyInfoSection(),
              const SizedBox(height: 24),
              // 캘린더 섹션
              _buildHistorySection(),
              const SizedBox(height: 24),
              // 최근 신청 내역
              _buildRecentRequestsSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomFooter(currentIndex: '/home'),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('HH:mm').format(DateTime.now()),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              const Text(
                'Hi, WelcomeBack',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
                color: Colors.grey,
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {},
                color: Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '나의 연차',
            style: context.textStyles.labelLarge.copyWith(
              color: context.appColors.primaryText,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF),
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 15,
                ),
                width: MediaQuery.of(context).size.width * 0.4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "미사용 연차",
                      style: context.textStyles.labelLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      //여기에 response.remained 데이터 출력,
                      "$remainedDays일",
                      style: context.textStyles.labelLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF),
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 15,
                ),
                width: MediaQuery.of(context).size.width * 0.4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "사용 연차",
                      style: context.textStyles.labelLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "$usedDays일",
                      style: context.textStyles.labelLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    // 1. 날짜 포맷팅 (yyyyMMdd -> yyyy.MM.dd)
    String formattedDate = historyDate;
    if (historyDate.length == 8) {
      formattedDate =
          "${historyDate.substring(0, 4)}.${historyDate.substring(4, 6)}.${historyDate.substring(6, 8)}";
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '사용 내역',
            style: context.textStyles.labelLarge.copyWith(
              color: context.appColors.primaryText,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 왼쪽 화살표: 이전 내역이 있을 때만 보임
                Opacity(
                  opacity: hasPrev == 'Y' ? 1.0 : 0.0,
                  child: IconButton(
                    icon: const Icon(
                      Icons.chevron_left,
                      color: Color(0xFF007AFF),
                      size: 32,
                    ),
                    onPressed: hasPrev == 'Y' ? _fetchPrevUsedHistory : null,
                  ),
                ),

                // 중앙 정보 영역: Expanded를 사용하여 오버플로우 방지
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formattedDate.isEmpty ? "-" : formattedDate,
                        style: const TextStyle(
                          color: Color(0xFF007AFF),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        historyreason.isEmpty ? "내역 없음" : historyreason,
                        textAlign: TextAlign.center,
                        // 텍스트가 너무 길어지면 줄바꿈 처리 및 오버플로우 방지
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // 오른쪽 화살표: 다음 내역이 있을 때만 보임
                Opacity(
                  opacity: hasNext == 'Y' ? 1.0 : 0.0,
                  child: IconButton(
                    icon: const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF007AFF),
                      size: 32,
                    ),
                    onPressed: hasNext == 'Y' ? _fetchNextUsedHistory : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRequestsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "사용 기록",
            style: context.textStyles.labelLarge.copyWith(
              color: context.appColors.primaryText,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),

          //휴가 종류 선택 (Segmented Toggle)
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE8EFFF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: ['연차', '반차', '반반차'].map((type) {
                bool isSelected = _selectedType == type;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _selectedType = type;
                      // 반차/반반차 선택 시 종료일을 시작일과 강제 동기화
                      if (type != '연차') _endDate = _startDate;
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF007AFF)
                            : Colors.transparent, // 선택시 0xFF007AFF 계열
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        type,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // --- 2. 시작일 선택 ---
          _buildDateField("시작일", _startDate, () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _startDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              locale: const Locale('ko', 'KR'),
            );
            if (picked != null) {
              setState(() {
                _startDate = picked;
                if (_endDate.isBefore(picked) || _selectedType != '연차') {
                  _endDate = picked;
                }
              });
            }
          }),

          // --- 3. 종료일 선택 ---
          _buildDateField("종료일", _endDate, () async {
            // 요구사항: 연차일 때만 변경 가능, 반차/반반차는 반응 없음
            if (_selectedType != '연차') return;

            final picked = await showDatePicker(
              context: context,
              initialDate: _endDate.isBefore(_startDate)
                  ? _startDate
                  : _endDate,
              firstDate: _startDate,
              lastDate: DateTime(2030),
              locale: const Locale('ko', 'KR'),
            );
            if (picked != null) setState(() => _endDate = picked);
          }),

          // --- 4. 사유 입력 ---
          const Text(
            "사유",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _reasonController,
            style: const TextStyle(
              color: Color(0xFF007AFF), // 타이핑 시에도 파란색으로 나오게 설정
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFE8EFFF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              hintText: "사유를 입력하세요",
              hintStyle: const TextStyle(
                color: Color(0xFF007AFF),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 30),
          // --- 저장 버튼 섹션 ---
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              // 로딩 중에는 클릭되지 않도록 null 처리
              onPressed: _isLoading ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              // 로딩 상태에 따라 텍스트 대신 빙글빙글 도는 인디케이터 표시
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "저장",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // 공통 날짜 필드 위젯
  Widget _buildDateField(String label, DateTime date, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EFFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}",
              style: const TextStyle(
                color: Color(0xFF007AFF),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
