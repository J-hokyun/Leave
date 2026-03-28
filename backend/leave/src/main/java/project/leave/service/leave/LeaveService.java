package project.leave.service.leave;

import java.text.DecimalFormat;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.stereotype.Service;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import project.leave.dto.leave.DeleteHistoryRequest;
import project.leave.dto.leave.LeaveCountsResponse;
import project.leave.dto.leave.LeaveHistoryRequest;
import project.leave.dto.leave.MonthlyListRequest;
import project.leave.dto.leave.UsedHistoryRequest;
import project.leave.dto.leave.UsedHistoryResponse;
import project.leave.entity.leave.LeaveHistory;
import project.leave.global.error.exception.LeaveCountOverException;
import project.leave.global.error.exception.ResourcesNotFoundException;
import project.leave.repository.leave.HolidayRepository;
import project.leave.repository.leave.LeaveHistoryRepository;
import project.leave.repository.user.UserLeaveTotRepository;
import project.leave.repository.user.UserRepository;

@Service
@Slf4j
@RequiredArgsConstructor
public class LeaveService {

    private final UserRepository userRepository;
    private final HolidayRepository holidayRepository;
    private final LeaveHistoryRepository leaveHistoryRepository;
    private final UserLeaveTotRepository leaveTotRepository;


    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
    String curYear = String.valueOf(LocalDateTime.now().getYear());

    /* 연차 사용 집계 로직 */
    public LeaveCountsResponse getUserLeaveCounts(String userId)
    {
        LeaveCountsResponse leaveCounts = new LeaveCountsResponse();

        Double used = calUsedLeave(userId);
        int totalCount = leaveTotRepository.findLeaveCountByUserIdAndYear(userId, curYear);
        Double remained = totalCount - used;

        DecimalFormat df = new DecimalFormat("###.##");

        leaveCounts.setUsed(df.format(used));
        leaveCounts.setRemained(df.format(remained));

        return leaveCounts;
    }


    /* 연차 저장 로직 */
    @Transactional
    public String saveLeaveHisory(LeaveHistoryRequest leaveRecordRequest, String userId)
    {
        log.debug("[LeaveService] start to saveLeaveHisory");
        LocalDate start = convertDate(leaveRecordRequest.getStartDate());
        LocalDate end = convertDate(leaveRecordRequest.getEndDate());
        int daysBetween = Math.toIntExact(ChronoUnit.DAYS.between(start, end));
        String parentId = genereteHistoryId();

        /* 주말 및 공휴일을 제외한 평일만 카운팅한 변수 */
        int weekDaysCount = calWeekDay(leaveRecordRequest.getStartDate(), leaveRecordRequest.getEndDate());
        if (!validLeftLeaveCount(userId, weekDaysCount, leaveRecordRequest.getLeaveTypeCode())){
            throw new LeaveCountOverException("잔여 연차가 부족합니다.");
        }


        for (int i = 0; i<=daysBetween; ++i)
        {
            String isHoliday = "N";
            String date = addDays(start, i);
            LocalDate localDate = LocalDate.parse(date, formatter);
            boolean isWeekend = (localDate.getDayOfWeek() == DayOfWeek.SATURDAY || 
                                localDate.getDayOfWeek() == DayOfWeek.SUNDAY);
            if (holidayRepository.existsByDate(date) ||  isWeekend){
                isHoliday = "Y";
            }

            LeaveHistory leaveHistory = LeaveHistory.builder()
            .id(genereteHistoryId())
            .userId(userId)
            .uuid(generateUuid())
            .date(date)
            .leaveReason(leaveRecordRequest.getLeaveReason())
            .leaveTypeCode(leaveRecordRequest.getLeaveTypeCode())
            .parentId(parentId)
            .isHoliday(isHoliday)
            .createdAt(LocalDateTime.now())
            .createdBy(userId)
            .updatedAt(LocalDateTime.now())
            .updatedBy(userId)
            .build();
            leaveHistoryRepository.save(leaveHistory);
        }
        return parentId;
    }

    /* 화면 최초 로딩시 현재일자 기준 최근 사용 내역 조회 로직 */
    public UsedHistoryResponse getCurrentUsedHistory(UsedHistoryRequest request)
    {
        log.debug("[LeaveService] get getCurrentUsedHistory");
        return leaveHistoryRepository.getCurrentHistory(request.getUserId());
    }

    /* 다음 사용내역 조회 로직 */
    public UsedHistoryResponse getNextUsedHistory(UsedHistoryRequest request)
    {
        log.debug("[LeaveService] get getNextUsedHistory");
        String id = leaveHistoryRepository.findIdByUuid(request.getUuid()).orElse(null);
        if (id == null)
        {
            throw new ResourcesNotFoundException("데이터 조회 중 오류가 생겼습니다.");
        }
        return leaveHistoryRepository.findFirstByAfterDate(request.getDate(), id, request.getUserId());

    }

    /* 이전 사용내역 조회 로직 */
    public UsedHistoryResponse getPrevUsedHistory(UsedHistoryRequest request)
    {
        log.debug("[LeaveService] get getPrevUsedHistory");
        String id = leaveHistoryRepository.findIdByUuid(request.getUuid()).orElse(null);
        if (id == null)
        {
            throw new ResourcesNotFoundException("데이터 조회 중 오류가 생겼습니다.");
        }
        return leaveHistoryRepository.findFirstByBeforeDate(request.getDate(), id, request.getUserId());
    }

    /* 월별 연차 사용내역 조회 로직 */
    public List<String>getMonthlyList(MonthlyListRequest request)
    {
        log.debug("[LeaveService] getMonthlyList");
        return leaveHistoryRepository.findAllByMounth(request.getDate(), request.getUserId());
    }
    
    /* 특정 날짜에 존재하는 연차 내역 조회 로직  */
    public List<LeaveHistory> getHistoryListByDate(String date, String userId){
        log.debug("[LeaveService] getHistoryListByDate date : {}, userId : {}", date, userId);
        List<LeaveHistory> leaveHistories = leaveHistoryRepository.findAllByDateAndUserId(date, userId);
        log.debug("[LeaveService] result count : {}", leaveHistories.size());
        return leaveHistories;
    }

    /* 삭제 하는 로직 */
    @Transactional
    public void deleteHistory(DeleteHistoryRequest request)
    {
        log.debug("[LeaveService] deleteHistory uuid : {}, userId : {}, code : {}", request.getUuid(), request.getUserId(), request.getCode());
        String parentId = getparetnId(request.getUuid());
        leaveHistoryRepository.deleteByParentId(parentId);  
    }

    /* 연차 내역 ID(PK) 생성 로직 */
    private String genereteHistoryId()
    {
        log.debug("[LeaveService] generate HistoryId start ");
        return leaveHistoryRepository.findByNewId();
    }

    /* String -> Date 로 파싱하는 로직 */
    private LocalDate convertDate(String date)
    {
        log.debug("[LeaveService] try convert to LocalDate from String ");
        return LocalDate.parse(date, formatter);
    }

    /* days만큼 date에 저장하여 반환하는 로직 */
    private String addDays(LocalDate date, int days)
    {
        log.debug("[LeaveService] try addDays ");
        LocalDate newDate = date.plusDays(days);
        return newDate.format(formatter);
    }

    /* 사용한 연차 집계 로직 */
    public Double calUsedLeave(String userId){
    log.debug("[LeaveService] try cal user leave sum for userId: {}", userId);
    Double leaveSum = 0.00;
    String curYear = String.valueOf(LocalDate.now().getYear());

    List<Map<String, Object>> leaveTypeCounts;
    /* 연차 공휴일 포함여부 에따른 쿼리 분기 */
    if (userRepository.findIsIncludeHolidayByUserId(userId).equals("N")){
        leaveTypeCounts = leaveHistoryRepository.findAllTypeCountsByUserIdAndYearAndNotIncludeHoliday(curYear, userId);
    }else{
        leaveTypeCounts = leaveHistoryRepository.findAllTypeCountsByUserIdAndYearAndIncludeHoliday(curYear, userId);
    }
    Map<String, Double> weights = Map.of(
        "0", 1.0,
        "1", 0.5,
        "2", 0.25
    );
    for (Map<String, Object> row : leaveTypeCounts) {
        String typeCode = String.valueOf(row.get("leave_type_code"));
        int count = ((Number) row.get("typeSum")).intValue();
        Double weight = weights.getOrDefault(typeCode, 0.0);
        leaveSum += (weight * count);
    }

    log.debug("[LeaveService] user {}'s total leave sum is : {}", userId, leaveSum);
    return leaveSum;
}

    /* 연차 등록전, 등록하려는 연차 갯수 검증 로직 */
    private boolean validLeftLeaveCount(String userId, int weekDaysCount, String code){
        
        /* 남은연차 계산 -> remaines에 저장 */
        Double used = calUsedLeave(userId);
        int totalCount = leaveTotRepository.findLeaveCountByUserIdAndYear(userId, curYear);
        Double remained = totalCount - used;
        
        /* 등록하고자 하는 연차계산. */
        Double saveCount = 0.0;
        if (code.equals("0")){
            saveCount = 1.0 * weekDaysCount;
        }else if (code.equals("1")){
            saveCount = 0.5 * weekDaysCount;
        }else{
            saveCount = 0.25 * weekDaysCount;
        }

        // 남은 연차 갯수 VS 등록하려는 연차갯수 비교
        log.debug("[validLeftLeaveCount] remained : {}, saveCount : {} ", remained, saveCount);
        if (remained >= saveCount){
            return true;
        }else{
            return false;
        }
    }

    /* 연차희망 시작일 ~ 종료일 구간에 실제 평일 계산하는 로직 */
    public int calWeekDay(String start, String end){
        log.debug("[LeaveService] start cal weekday");
        int result = 0;

        LocalDate startDate = LocalDate.parse(start, formatter);
        LocalDate endDate = LocalDate.parse(end, formatter);
        
        for (LocalDate date = startDate; !date.isAfter(endDate); date = date.plusDays(1)){
            if (date.getDayOfWeek()==DayOfWeek.SATURDAY || date.getDayOfWeek() == DayOfWeek.SUNDAY){
                continue;
            }else if (holidayRepository.existsByDate(date.format(formatter))){
                continue;
            }else{
                result++;
            }
        }
        log.debug("[LeaveService] cal weekday result is : {}", result);
        return result;
    }

    /* UUID 생성 로직 */
    private UUID generateUuid()
    {   log.debug("[LeaveService] generateUuid start");
        return UUID.randomUUID();
    }

    public UUID getUuidById(String id)
    {   log.debug("[LeaveService] getUuid is start id : {}", id);
        return leaveHistoryRepository.findUuidById(id).orElse(null);
    }

    public String getIdByUuid(UUID uuid)
    {   log.debug("[LeaveService] getId is start uuid is {}", uuid);
        return leaveHistoryRepository.findIdByUuid(uuid).orElse(null);
    }

    private String getparetnId(UUID uuid)
    {
        log.debug("[] getparetnId is start ");
        return leaveHistoryRepository.findParentId(uuid);

    }
    
    
}
