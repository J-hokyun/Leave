package project.leave.service.leave;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

import java.text.DecimalFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.UUID;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import jakarta.transaction.Transactional;
import project.leave.dto.leave.DeleteHistoryRequest;
import project.leave.dto.leave.LeaveCountsResponse;
import project.leave.dto.leave.LeaveHistoryRequest;
import project.leave.dto.leave.MonthlyListRequest;
import project.leave.dto.leave.UsedHistoryRequest;
import project.leave.dto.leave.UsedHistoryResponse;

import project.leave.entity.leave.LeaveHistory;
import project.leave.global.error.exception.LeaveCountOverException;

import project.leave.repository.leave.LeaveHistoryRepository;


@SpringBootTest 
@Transactional  
public class LeaveServiceTest {

    @Autowired
    private LeaveService leaveService;

    @Autowired
    private LeaveHistoryRepository leaveHistoryRepository;

    private String testUserId = "user2026032600001";

    private String curYear = String.valueOf(LocalDateTime.now().getYear());

    DecimalFormat df = new DecimalFormat("###.##");

    @Test
    @DisplayName("연차 등록 건수 테스트 [단건]")
    void saveLeaveHisoryTest()
    {
        String startDate = curYear + "0219";
        String endDate = curYear + "0219";

        LeaveHistoryRequest historyRequest = LeaveHistoryRequest.builder()
        .startDate(startDate)
        .endDate(endDate)
        .leaveTypeCode("0")
        .leaveReason("휴가")
        .build();

        leaveService.saveLeaveHisory(historyRequest, testUserId);
        Double used = leaveService.calUsedLeave(testUserId);

        // 저장 건수 확인.
        assertEquals(1, leaveHistoryRepository.countByUserId(testUserId));
        assertEquals("1", df.format(used));
    }

    @Test
    @DisplayName("연차 등록 건수 테스트 [다건]")
    void saveLeaveHisoriesTest()
    {
        String startDate = curYear + "0309";
        String endDate = curYear + "0327";

        LeaveHistoryRequest historyRequest = LeaveHistoryRequest.builder()
        .startDate(startDate)
        .endDate(endDate)
        .leaveTypeCode("0")
        .leaveReason("휴가")
        .build();

        leaveService.saveLeaveHisory(historyRequest, testUserId);
        Double used = leaveService.calUsedLeave(testUserId);

        // 저장 건수 확인.
        assertEquals(19, leaveHistoryRepository.countByUserId(testUserId));
        assertEquals("15", df.format(used));
    }

    @Test
    @DisplayName("연차 등록 건수 테스트 [다건, 주말포함]")
    void saveLeaveHisoriesIncludeHolidayTest()
    {
        String startDate = curYear + "0213";
        String endDate = curYear + "0219";

        LeaveHistoryRequest historyRequest = LeaveHistoryRequest.builder()
        .startDate(startDate)
        .endDate(endDate)
        .leaveTypeCode("0")
        .leaveReason("휴가")
        .build();

        leaveService.saveLeaveHisory(historyRequest, testUserId);
        Double used = leaveService.calUsedLeave(testUserId);

        // 저장 건수 확인.
        assertEquals(7, leaveHistoryRepository.countByUserId(testUserId));
        assertEquals("2", df.format(used));
    }

    @Test
    @DisplayName("연차 등록 실패 테스트(남은 연차 갯수 초과)")
    void saveLeaveHisoriesFaliTest()
    {
        String startDate = curYear + "0316";
        String endDate = curYear + "0406";

        LeaveHistoryRequest historyRequest = LeaveHistoryRequest.builder()
        .startDate(startDate)
        .endDate(endDate)
        .leaveTypeCode("0")
        .leaveReason("휴가")
        .build();

        assertThrows(LeaveCountOverException.class, () -> {
            leaveService.saveLeaveHisory(historyRequest, testUserId);
        });
    }

    @Test
    @DisplayName("잔여, 사용 연차 출력 테스트")
    void printUsedAndRemainedDaysTest()
    {
        LeaveHistoryRequest historyRequest1 = LeaveHistoryRequest.builder() //2
        .startDate("20260218")
        .endDate("20260222")
        .leaveTypeCode("0")
        .leaveReason("휴가")
        .build();

        LeaveHistoryRequest historyRequest2 = LeaveHistoryRequest.builder() // 0.5
        .startDate("20260219")
        .endDate("20260219")
        .leaveTypeCode("1")
        .leaveReason("휴가")
        .build();

        LeaveHistoryRequest historyRequest3 = LeaveHistoryRequest.builder() //0.25
        .startDate("20260220")
        .endDate("20260220")
        .leaveTypeCode("2")
        .leaveReason("휴가")
        .build();

        leaveService.saveLeaveHisory(historyRequest1, testUserId);
        leaveService.saveLeaveHisory(historyRequest2, testUserId);
        leaveService.saveLeaveHisory(historyRequest3, testUserId);

        LeaveCountsResponse leaveCountsResponse = leaveService.getUserLeaveCounts(testUserId);

        assertEquals("2.75", leaveCountsResponse.getUsed());
        assertEquals("12.25", leaveCountsResponse.getRemained());

    }
    
    @Test
    @DisplayName("현재일자 사용 내역 조회 테스트")
    void getCurrentHistoryTest()
    {
        LocalDateTime now = LocalDateTime.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
        
        // 3. 날짜 계산 및 String 변환
        String today = now.format(formatter);
        String tomorrow = now.plusDays(1).format(formatter);
        String yesterday = now.minusDays(1).format(formatter);


        LeaveHistoryRequest todayRequest = LeaveHistoryRequest.builder()
        .startDate(today)
        .endDate(today)
        .leaveTypeCode("0")
        .leaveReason("휴가")
        .build();

        LeaveHistoryRequest tomorrowRequest = LeaveHistoryRequest.builder()
        .startDate(tomorrow)
        .endDate(tomorrow)
        .leaveTypeCode("0")
        .leaveReason("휴가")
        .build();

        LeaveHistoryRequest yesterdayRequest = LeaveHistoryRequest.builder()
        .startDate(yesterday)
        .endDate(yesterday)
        .leaveTypeCode("0")
        .leaveReason("휴가")
        .build();

        leaveService.saveLeaveHisory(todayRequest, testUserId);
        leaveService.saveLeaveHisory(tomorrowRequest, testUserId);
        leaveService.saveLeaveHisory(yesterdayRequest, testUserId);
        

        UsedHistoryRequest usedHistoryRequest = UsedHistoryRequest.builder().userId(testUserId).build();
        UsedHistoryResponse usedHistoryResponse = leaveService.getCurrentUsedHistory(usedHistoryRequest);

        assertEquals(today, usedHistoryResponse.getDate());
    }
    @Test
    @DisplayName("다음 사용 내역 조회 테스트")
    void getNextHistoryTest()
    {
        LocalDateTime now = LocalDateTime.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
        
        // 3. 날짜 계산 및 String 변환
        String today = now.format(formatter);
        String tomorrow = now.plusDays(1).format(formatter);

        LeaveHistoryRequest todayRequest = LeaveHistoryRequest.builder()
        .startDate(today)
        .endDate(today)
        .leaveTypeCode("0")
        .leaveReason("휴가")
        .build();

        LeaveHistoryRequest tomorrowRequest = LeaveHistoryRequest.builder()
        .startDate(tomorrow)
        .endDate(tomorrow)
        .leaveTypeCode("0")
        .leaveReason("다음날휴가")
        .build();


        String todayId = leaveService.saveLeaveHisory(todayRequest, testUserId);
        String tomorrowId = leaveService.saveLeaveHisory(tomorrowRequest, testUserId);

        UUID todayUuid = leaveService.getUuidById(todayId);
        UUID tomorrowUuid = leaveService.getUuidById(tomorrowId);

        UsedHistoryRequest usedHistoryRequest = UsedHistoryRequest.builder()
                                                .date(today)
                                                .uuid(todayUuid)
                                                .userId(testUserId).build();

        UsedHistoryResponse usedHistoryResponse = leaveService.getNextUsedHistory(usedHistoryRequest);

        assertEquals(tomorrow, usedHistoryResponse.getDate());
        assertEquals(tomorrowUuid, usedHistoryResponse.getUuid());
        assertEquals("N", usedHistoryResponse.getHasNext());
        assertEquals("Y", usedHistoryResponse.getHasPrev());
    }
    
    @Test
    @DisplayName("이전 사용 내역 조회 테스트")
    void getPrevHistoryTest()
    {
        LocalDateTime now = LocalDateTime.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
        
        // 3. 날짜 계산 및 String 변환
        String today = now.format(formatter);
        String yesterday = now.plusDays(-1).format(formatter);

        LeaveHistoryRequest todayRequest = LeaveHistoryRequest.builder()
        .startDate(today)
        .endDate(today)
        .leaveTypeCode("0")
        .leaveReason("휴가")
        .build();

        LeaveHistoryRequest yesterdayRequest = LeaveHistoryRequest.builder()
        .startDate(yesterday)
        .endDate(yesterday)
        .leaveTypeCode("0")
        .leaveReason("이전날 휴가")
        .build();


        String todayId = leaveService.saveLeaveHisory(todayRequest, testUserId);
        String yesterdayId = leaveService.saveLeaveHisory(yesterdayRequest, testUserId);

        UUID todayUuid = leaveService.getUuidById(todayId);
        UUID yesterdayUuid = leaveService.getUuidById(yesterdayId);

        UsedHistoryRequest usedHistoryRequest = UsedHistoryRequest.builder()
                                                .date(today)
                                                .uuid(todayUuid)
                                                .userId(testUserId).build();

        UsedHistoryResponse usedHistoryResponse = leaveService.getPrevUsedHistory(usedHistoryRequest);

        assertEquals(yesterday, usedHistoryResponse.getDate());
        assertEquals(yesterdayUuid, usedHistoryResponse.getUuid());
        assertEquals("Y", usedHistoryResponse.getHasNext());
        assertEquals("N", usedHistoryResponse.getHasPrev());
    }
    
    @Test
    @DisplayName("월별 연차 사용 내역 조회 테스트")
    void getMonthlyListTest()
    {
        LeaveHistoryRequest historyRequest1 = LeaveHistoryRequest.builder()
        .startDate("20260215")
        .endDate("20260215")
        .leaveTypeCode("0")
        .leaveReason("휴가")
        .build();

        LeaveHistoryRequest historyRequest2 = LeaveHistoryRequest.builder()
        .startDate("20260216")
        .endDate("20260216")
        .leaveTypeCode("0")
        .leaveReason("휴가")
        .build();

        LeaveHistoryRequest historyRequest3 = LeaveHistoryRequest.builder()
        .startDate("20260217")
        .endDate("20260217")
        .leaveTypeCode("0")
        .leaveReason("휴가")
        .build();

        LeaveHistoryRequest historyRequest4 = LeaveHistoryRequest.builder()
        .startDate("20260218")
        .endDate("20260218")
        .leaveTypeCode("0")
        .leaveReason("휴가")
        .build();
        
        LeaveHistoryRequest historyRequest5 = LeaveHistoryRequest.builder()
        .startDate("20260301")
        .endDate("20260301")
        .leaveTypeCode("0")
        .leaveReason("휴가")
        .build();        

        leaveService.saveLeaveHisory(historyRequest1, testUserId);
        leaveService.saveLeaveHisory(historyRequest2, testUserId);
        leaveService.saveLeaveHisory(historyRequest3, testUserId);
        leaveService.saveLeaveHisory(historyRequest4, testUserId);
        leaveService.saveLeaveHisory(historyRequest5, testUserId);

        MonthlyListRequest request = MonthlyListRequest.builder().date("20260228").userId(testUserId).build();

        List<String>result = leaveService.getMonthlyList(request);
        assertEquals(4, result.size());
    }
    
    
    @Test
    @DisplayName("특정일자 연차 사용 내역 조회 테스트")
    void getLeaveHistoryByDate()
    {
        LeaveHistoryRequest historyRequest1 = LeaveHistoryRequest.builder()
        .startDate("20260215")
        .endDate("20260215")
        .leaveTypeCode("0")
        .leaveReason("휴가")
        .build();

        LeaveHistoryRequest historyRequest2 = LeaveHistoryRequest.builder()
        .startDate("20260216")
        .endDate("20260216")
        .leaveTypeCode("0")
        .leaveReason("휴가")
        .build();

        LeaveHistoryRequest historyRequest3 = LeaveHistoryRequest.builder()
        .startDate("20260217")
        .endDate("20260217")
        .leaveTypeCode("0")
        .leaveReason("휴가")
        .build();

        leaveService.saveLeaveHisory(historyRequest1, testUserId);
        leaveService.saveLeaveHisory(historyRequest2, testUserId);
        leaveService.saveLeaveHisory(historyRequest3, testUserId);

        List<LeaveHistory> responses = leaveService.getHistoryListByDate("20260216", testUserId);

        assertEquals(1, responses.size());
    }
    
    @Test
    @DisplayName("연차내역 삭제 테스트")
    void deleteHistoryTest()
    {
        LeaveHistoryRequest historyRequest1 = LeaveHistoryRequest.builder()
        .startDate("20260223")
        .endDate("20260223")
        .leaveTypeCode("0")
        .leaveReason("휴가")
        .build();

        LeaveHistoryRequest historyRequest2 = LeaveHistoryRequest.builder()
        .startDate("20260224")
        .endDate("20260224")
        .leaveTypeCode("0")
        .leaveReason("휴가")
        .build();

        LeaveHistoryRequest historyRequest3 = LeaveHistoryRequest.builder()
        .startDate("20260225")
        .endDate("20260225")
        .leaveTypeCode("0")
        .leaveReason("휴가")
        .build();


        String historyId1 = leaveService.saveLeaveHisory(historyRequest1, testUserId);
        String historyId2 = leaveService.saveLeaveHisory(historyRequest2, testUserId);
        String historyId3 = leaveService.saveLeaveHisory(historyRequest3, testUserId);

        leaveService.getUuidById(historyId1);
        leaveService.getUuidById(historyId2);
        UUID historyUuid3 = leaveService.getUuidById(historyId3);

        // 2번째 히스토리 삭제.
        DeleteHistoryRequest request = DeleteHistoryRequest.builder()
                                        .uuid(historyUuid3)
                                        .userId(testUserId)
                                        .code("0")
                                        .build();
        leaveService.deleteHistory(request);
        
        LeaveCountsResponse leaveCountsResponse = leaveService.getUserLeaveCounts(testUserId);

        assertEquals(null, leaveService.getUuidById(historyId3));
        assertEquals("2", leaveCountsResponse.getUsed());
        assertEquals("13", leaveCountsResponse.getRemained());
    }
    
    @Test
    @DisplayName("시작 ~ 종료일 구간 평일 계산 로직 테스트")
    void calWeekDayCountTest(){
        int result1 = leaveService.calWeekDay("20260227", "20260303");
        int result2 = leaveService.calWeekDay("20260601", "20260605");
        int result3 = leaveService.calWeekDay("20260313", "20260315");
        int result4 = leaveService.calWeekDay("20260316", "20260316");
        int result5 = leaveService.calWeekDay("20260316", "20260318");

        assertEquals(2, result1);
        assertEquals(4, result2);
        assertEquals(1, result3);
        assertEquals(1, result4);
        assertEquals(3, result5);
    }
}
