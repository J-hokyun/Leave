import 'package:flutter/material.dart';
import 'package:leave_application/presentation/common/footer.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:leave_application/data/api/leave_api.dart';
import 'package:leave_application/presentation/common/alert_utils.dart';
import 'package:dio/dio.dart';

var logger = Logger(
  printer: PrettyPrinter(), // 로그를 보기 좋게 박스 형태로 출력해줌
);

class CalenderPage extends StatefulWidget {
  const CalenderPage({super.key});

  @override
  State<CalenderPage> createState() => _CalenderPageState();
}

class _CalenderPageState extends State<CalenderPage> {
  final LeaveApi _leaveApi = LeaveApi();
  bool _isLoading = false;

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  List<dynamic> _dailyHistoryList = [];

  List<DateTime> _leaveDays = [];

  Future<void> _getMonthlyList() async {
    try {
      final response = await _leaveApi.getMonthlyList(date: _focusedDay);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        setState(() {
          _leaveDays = data.map((item) {
            String dateStr = item['date']; // 서버 DTO의 필드명 "date"
            int year = int.parse(dateStr.substring(0, 4));
            int month = int.parse(dateStr.substring(4, 6));
            int day = int.parse(dateStr.substring(6, 8));

            return DateTime(year, month, day);
          }).toList();
        });

        logger.d("조회된 휴가 날짜 수: ${_leaveDays.length}");
      }
    } catch (e) {
      logger.d("월별 리스트 조회 실패: $e");
    }
  }

  Future<void> _getHistoryByDate(DateTime date) async {
    try {
      logger.d("터치된 날짜 : $date");
      final response = await _leaveApi.getHistoryByDate(date: date);

      if (response.statusCode == 200) {
        setState(() {
          // 서버에서 받아온 리스트 데이터를 상태 변수에 할당
          _dailyHistoryList = response.data;
        });
      }
    } catch (e) {
      logger.d("일별 리스트 조회 실패: $e");
      setState(() {
        _dailyHistoryList = []; // 에러 시 리스트 초기화
      });
    }
  }

  // 연차 사용 내역 삭제 호출 API
  Future<void> _deleteHistory({
    required String uuid,
    required String code,
  }) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final response = await _leaveApi.deleteHistory(
        uuid: uuid,
        userId: "",
        code: code,
      );

      if (response.statusCode == 200) {
        await _getHistoryByDate(_selectedDay);
        await _getMonthlyList();

        logger.d("데이터 삭제 완료");
        if (!mounted) return;
        AlertUtils.showAlert(context, '삭제 완료되었습니다.');

        setState(() {});
      }
    } catch (e) {
      String errorMessage = "오류가 발생했습니다. 다시 시도하여 주세요.";

      if (e is DioException && e.response != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      } else {
        errorMessage = e.toString();
      }

      logger.d("삭제 실패 : $errorMessage");
      if (!mounted) return;
      AlertUtils.showError(context, errorMessage);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _getMonthlyList();
    _getHistoryByDate(_selectedDay);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // --- 상단 달력 영역 (연한 파란색 배경) ---
          Container(
            padding: const EdgeInsets.only(top: 60, bottom: 20),
            decoration: const BoxDecoration(
              color: Color(0xFFE8EFFF),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(children: [_buildTableCalendar()]),
          ),

          // --- 하단 상세 내역 영역 ---
          Expanded(
            child: SingleChildScrollView(
              // 내용이 많아질 경우를 대비
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${_selectedDay.day}일 ${DateFormat('EEEE', 'ko_KR').format(_selectedDay)}",
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4357FF), // 강조된 파란색
                      ),
                    ),

                    const SizedBox(height: 25),
                    ..._dailyHistoryList.map((item) {
                      return _buildHistoryItem(item);
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomFooter(currentIndex: '/calendar'),
    );
  } // --- 개별 휴가 아이템 빌더 (사진의 디자인 재현) ---

  // 상세 내역 빌드
  Widget _buildHistoryItem(Map<String, dynamic> item) {
    final String uuid = item['uuid'] ?? "";
    final String typeName = item['leaveTypeName'] ?? "미지정";
    final String typeCode = item['leaveTypeCode'];
    final String reason = item['leaveReason'] ?? "사유 없음";

    return Row(
      children: [
        // 연차 태그 (원형 배경)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE8EFFF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            typeName,
            style: const TextStyle(
              color: Color(0xFF4357FF),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
        const SizedBox(width: 15),

        // 사유 텍스트
        Expanded(
          child: Text(
            reason,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),

        // 수정/삭제 아이콘 (연한 파란색 동그라미 배경)
        // _buildActionIcon(
        //   Icons.edit_outlined,
        //   onTap: () => _showEditSheet(
        //     context: context,
        //     uuid: uuid,
        //     typeCode: typeCode,
        //     reason: reason,
        //     selectedDate: _selectedDay,
        //   ),
        // ),
        const SizedBox(width: 10),
        _buildActionIcon(
          Icons.delete_outline,
          onTap: () => _showDeleteConfirmDialog(uuid, typeCode),
        ),
      ],
    );
  }

  // 아이콘 버튼 스타일
  Widget _buildActionIcon(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Color(0xFFE8EFFF),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF4357FF)),
      ),
    );
  }

  /* 달력부분 빌드 */
  Widget _buildTableCalendar() {
    return TableCalendar(
      locale: 'ko_KR',
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2100, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

      /* 날짜 터치 했을 때 */
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });

        _getHistoryByDate(selectedDay);
      },

      /* 달력을 변경 했을 때 */
      onPageChanged: (focusedDay) {
        final firstDayOfMonth = DateTime(focusedDay.year, focusedDay.month, 1);
        setState(() {
          _focusedDay = firstDayOfMonth;
          _selectedDay = firstDayOfMonth;
        });
        _getMonthlyList();
        _getHistoryByDate(firstDayOfMonth);
      },

      // --- 이벤트(파란 점) 설정 ---
      eventLoader: (day) {
        if (_leaveDays.any((d) => isSameDay(d, day))) {
          return ['leave'];
        }
        return [];
      },

      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          if (events.isNotEmpty) {
            return Positioned(
              bottom: 0.5, // 점의 위치를 원 안쪽 하단으로 적절히 배치
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  // 선택된 날짜라면 흰색 점으로, 아니면 원래의 파란색 점으로 표시
                  color: const Color(0xFF007AFF),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }
          return null;
        },
      ),

      // --- 헤더 스타일 (화살표 및 월 표시) ---
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF007AFF),
        ),
        leftChevronIcon: Icon(
          Icons.arrow_back_ios,
          size: 18,
          color: Color(0xFF007AFF),
        ),
        rightChevronIcon: Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: Color(0xFF007AFF),
        ),
      ),

      // --- 달력 디자인 커스텀 ---
      calendarStyle: const CalendarStyle(
        defaultTextStyle: TextStyle(color: Colors.black),
        weekendTextStyle: TextStyle(color: Colors.red),

        // 선택된 날짜 (진한 파랑 원)
        selectedDecoration: BoxDecoration(
          color: Color(0xFF007AFF),
          shape: BoxShape.circle,
        ),
        cellMargin: EdgeInsets.all(10),

        // 오늘 날짜 (연한 파랑 배경에 파란 글씨)
        todayDecoration: BoxDecoration(
          color: Color(0xFFE8EFFF),
          shape: BoxShape.circle,
        ),
        todayTextStyle: TextStyle(
          color: Color(0xFF007AFF),
          fontWeight: FontWeight.bold,
        ),

        // 기본 마커 설정은 유지 (builder가 없을 때 대비)
        markerDecoration: BoxDecoration(
          color: Color(0xFF007AFF),
          shape: BoxShape.circle,
        ),
        markersAlignment: Alignment.bottomCenter,
      ),

      // --- 요일 스타일 ---
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.bold,
        ),
        weekendStyle: TextStyle(
          color: Colors.redAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /* 수정 버튼 터치 후 팝업창 호출 */
  void _showEditSheet({
    required BuildContext context,
    required String uuid,
    required String typeCode, // 0, 1, 2
    required String reason,
    required DateTime selectedDate,
  }) {
    final List<String> types = ['연차', '반차', '반반차'];
    int initialIndex = int.tryParse(typeCode) ?? 0;
    String currentSelectedType = types[initialIndex];

    String formattedDate =
        "${selectedDate.year}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.day.toString().padLeft(2, '0')}";

    TextEditingController reasonController = TextEditingController(
      text: reason,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        // 내부 상태 변경을 위해 StatefulBuilder 사용
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "연차 수정",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4357FF),
                ),
              ),
              const SizedBox(height: 25),

              // [탭 로직 수정] 연차/반차/반반차 탭
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EFFF),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: types.asMap().entries.map((entry) {
                    int index = entry.key;
                    String type = entry.value;
                    bool isSelected = currentSelectedType == type;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setModalState(() {
                          currentSelectedType = type;
                          // 필요 시 여기서 추가 로직 수행 (예: 코드값 저장)
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF4357FF)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            type,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(
                                      0xFF4357FF,
                                    ).withValues(alpha: 0.5),
                              fontSize: 16, // 기존 20은 다소 클 수 있어 조정
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 25),

              // 전달받은 날짜 표시
              _buildPopupField("시작일", formattedDate),
              const SizedBox(height: 15),
              _buildPopupField("종료일", formattedDate),
              const SizedBox(height: 25),

              const Text(
                "사유",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: reasonController, // 기존 사유 바인딩
                decoration: InputDecoration(
                  hintText: "사유를 입력하세요",
                  filled: true,
                  fillColor: const Color(0xFFE8EFFF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const Spacer(),

              // 저장 버튼 (UUID와 변경된 데이터 활용)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4357FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "수정하기",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopupField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFFE8EFFF),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF4357FF),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmDialog(String uuid, String typeCode) {
    showDialog(
      context: context,
      barrierDismissible: false, // 배경 클릭으로 닫히지 않게 설정
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white, // 배경색 유지 (Material3 대응)
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: const Text(
              "해당 연차 내역을 삭제하시겠습니까?",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          actions: [
            Row(
              children: [
                // 취소 버튼
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      "취소",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey, // 취소는 상대적으로 차분한 색상
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                // 구분선 스타일의 여백
                const SizedBox(width: 10),
                // 삭제 버튼
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _deleteHistory(uuid: uuid, code: typeCode);
                    },
                    child: const Text(
                      "삭제",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.redAccent, // 삭제 강조를 위해 레드 계열 사용
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
