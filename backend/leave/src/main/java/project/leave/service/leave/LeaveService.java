package project.leave.service.leave;

import java.text.DecimalFormat;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.List;
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
import project.leave.entity.leave.LeaveDetail;
import project.leave.entity.leave.LeaveHistory;
import project.leave.entity.user.User;
import project.leave.global.error.exception.ResourcesNotFoundException;
import project.leave.repository.leave.LeaveDetailRepository;
import project.leave.repository.leave.LeaveHistoryRepository;
import project.leave.repository.user.UserRepository;

@Service
@Slf4j
@RequiredArgsConstructor
public class LeaveService {

    private final LeaveHistoryRepository leaveHistoryRepository;
    private final LeaveDetailRepository leaveDetailRepository;
    private final UserRepository userRepository;

    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");

    /* 연차 사용 집계 로직 */
    public LeaveCountsResponse getUserLeaveCounts(String userId)
    {
        LeaveCountsResponse leaveCounts = new LeaveCountsResponse();

        User user = userRepository.findById(userId).orElse(null);
        List<LeaveDetail>leaveDetails = leaveDetailRepository.findAllByUserId(userId).orElse(null);

        Double used = calUsedLeave(leaveDetails);
        Double remained = user.getTotalLeaveCount() - used;

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

        for (int i = 0; i<=daysBetween; ++i)
        {
            LeaveHistory leaveHistory = LeaveHistory.builder()
            .id(genereteHistoryId())
            .userId(userId)
            .uuid(generateUuid())
            .date(addDays(start, i))
            .leaveReason(leaveRecordRequest.getLeaveReason())
            .leaveTypeCode(leaveRecordRequest.getLeaveTypeCode())
            .parentId(parentId)
            .createdAt(LocalDateTime.now())
            .createdBy(userId)
            .updatedAt(LocalDateTime.now())
            .updatedBy(userId)
            .build();
            leaveHistoryRepository.save(leaveHistory);
        }

        /* 연차 종류별 카운팅을 집계 테이블 반영 */
        LeaveDetail leaveDetail = getLeaveDetail(userId, leaveRecordRequest.getLeaveTypeCode());
        if (leaveDetail == null)
        {
            leaveDetail = LeaveDetail.builder()
            .id(generateDetailId())
            .userId(userId)
            .leaveTypeCode(leaveRecordRequest.getLeaveTypeCode())
            .usedCount(daysBetween + 1)
            .createdBy(userId)
            .createdAt(LocalDateTime.now())
            .updatedBy(userId)
            .updatedAt(LocalDateTime.now())
            .build();

            leaveDetailRepository.save(leaveDetail);
        }else{
            leaveDetail.addUsedCount(daysBetween + 1, userId);
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

        int deleteCount = leaveHistoryRepository.deleteByParentId(parentId);  

        LeaveDetail leaveDetail = leaveDetailRepository.findByUserIdAndCode(request.getUserId(), request.getCode()).orElse(null);
        
        if (leaveDetail == null){
            throw new ResourcesNotFoundException("삭제 중 오류가 생겼습니다. 다시 시도 하여 주세요");
        }

        int newCount = Math.max(0, leaveDetail.getUsedCount() - deleteCount );
        leaveDetail.setUsedCount(newCount);
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

    /* 연차타입별 갯수를 집계하는 테이블에서 정보를 조회하는 로직 */
    private LeaveDetail getLeaveDetail (String userId, String code)
    {
        log.debug("[LeaveService] getLeaveDetail ");
        return leaveDetailRepository.findByUserIdAndCode(userId, code).orElse(null);
    }

    /* 갯수 집계 테이블의 ID(PK) 를 생성하는 로직 */
    private String generateDetailId ()
    {
        log.debug("[LeaveService] generate DetailId start");
        return leaveDetailRepository.getNewId();
    }

    /* 연차 집계 테이블에서 조회된 정보를 바탕으로 전체 사용 갯수를 집계하는 로직 */
    private Double calUsedLeave(List<LeaveDetail> leaveDetails)
    {
        log.debug("[LeaveService] try cal user leave sum");
        Double leaveSum = 0.00;
        for (LeaveDetail leaveDetail : leaveDetails)
        {
            if (leaveDetail.getLeaveTypeCode().equals("0"))
            {
                leaveSum += (1 * leaveDetail.getUsedCount());
            }else if(leaveDetail.getLeaveTypeCode().equals("1")){
                leaveSum += (0.5 * leaveDetail.getUsedCount());
            }else{
                leaveSum += (0.25 * leaveDetail.getUsedCount());
            }
        }
        log.debug("[LeaveService] user leave sum is : {}", leaveSum);
        return leaveSum;
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
