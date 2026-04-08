package project.leave.controller.leave;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import project.leave.dto.leave.DeleteHistoryRequest;
import project.leave.dto.leave.LeaveCountsResponse;
import project.leave.dto.leave.LeaveHistoryByDateResponse;
import project.leave.dto.leave.LeaveHistoryRequest;
import project.leave.dto.leave.MonthlyListRequest;
import project.leave.dto.leave.MonthlyListResponse;
import project.leave.dto.leave.UsedHistoryRequest;
import project.leave.dto.leave.UsedHistoryResponse;
import project.leave.dto.leave.YearlyListRequest;
import project.leave.dto.leave.YearlyListResponse;
import project.leave.entity.leave.LeaveHistory;
import project.leave.service.leave.LeaveService;

import java.util.LinkedList;
import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestParam;




@RestController
@Slf4j
@RequiredArgsConstructor
@RequestMapping("/api/leave")
public class LeaveController {

    private final LeaveService leaveService;
    @PostMapping("/history")
    public ResponseEntity<?> saveLeaveHistory(@RequestBody LeaveHistoryRequest leaveHistoryRequest, @AuthenticationPrincipal String userId) {

        log.debug("[LeaveController] POST /api/leave/history");
        leaveService.saveLeaveHisory(leaveHistoryRequest, userId);
        return ResponseEntity.ok("good");
    }

    @GetMapping("/count")
    public ResponseEntity<LeaveCountsResponse> getLeaveCount(@AuthenticationPrincipal String userId) {
        log.debug("[LeaveController] GET /api/leave/count");
        LeaveCountsResponse leaveCountsResponse =  leaveService.getUserLeaveCounts(userId);

        return ResponseEntity.ok(leaveCountsResponse);
    }

    @GetMapping("/current")
    public ResponseEntity<UsedHistoryResponse> getCurrentUsed(@ModelAttribute UsedHistoryRequest usedHistoryRequest, @AuthenticationPrincipal String userId) {
        log.debug("[LeaveController] GET /api/leave/current");

        usedHistoryRequest.setUserId(userId);
        UsedHistoryResponse usedHistoryResponse =  leaveService.getCurrentUsedHistory(usedHistoryRequest);
        if (usedHistoryResponse == null)
        {
            return ResponseEntity.ok(new UsedHistoryResponse());
        }
        return ResponseEntity.ok(usedHistoryResponse);
    }

    @GetMapping("/next")
    public ResponseEntity<UsedHistoryResponse> getNextUsed(@ModelAttribute UsedHistoryRequest usedHistoryRequest, @AuthenticationPrincipal String userId) {
        log.debug("[LeaveController] GET /api/leave/next");

        usedHistoryRequest.setUserId(userId);
        UsedHistoryResponse usedHistoryResponse =  leaveService.getNextUsedHistory(usedHistoryRequest);
        return ResponseEntity.ok(usedHistoryResponse);
    }

    @GetMapping("/prev")
    public ResponseEntity<UsedHistoryResponse> getPrevUsed(@ModelAttribute UsedHistoryRequest usedHistoryRequest, @AuthenticationPrincipal String userId) {
        log.debug("[LeaveController] GET /api/leave/prev");

        usedHistoryRequest.setUserId(userId);        
        UsedHistoryResponse usedHistoryResponse =  leaveService.getPrevUsedHistory(usedHistoryRequest);
        return ResponseEntity.ok(usedHistoryResponse);
    }

    @GetMapping("/monthly")
    public ResponseEntity<List<MonthlyListResponse>> getMonthlyList(@ModelAttribute MonthlyListRequest monthlyListRequest, @AuthenticationPrincipal String userId) {
        log.debug("[LeaveController] GET /api/leave/monthly");
        List<MonthlyListResponse> listResponses = new LinkedList<>();
        monthlyListRequest.setUserId(userId);

        List<String> MonthlyList = leaveService.getMonthlyList(monthlyListRequest);
        for (String date : MonthlyList)
        {
            listResponses.add(new MonthlyListResponse(date));
        }
        
        return ResponseEntity.ok(listResponses);
    }

    @GetMapping("/yearly")
    public ResponseEntity<List<YearlyListResponse>> getYearlyList(@RequestParam("date") String date, @AuthenticationPrincipal String userId) {
        log.debug("[LeaveController] GET /api/leave/yearly");
        List<YearlyListResponse> listResponses = new LinkedList<>();
        List<LeaveHistory> yearlyList = leaveService.getYearlyList(userId, date);
        for (LeaveHistory history : yearlyList)
        {
            listResponses.add(new YearlyListResponse(history));
        }
        
        return ResponseEntity.ok(listResponses);
    }

    @GetMapping("/yearly/count")
    public ResponseEntity<?> getYearlyUsedCount(@RequestParam("date") String date, @AuthenticationPrincipal String userId) {
        log.debug("[LeaveController] GET /api/leave/yearly/count");
        String yearlySum = leaveService.sumUsedLeaveInYear(userId, date);
        return ResponseEntity.ok(yearlySum);
    }
    

    @GetMapping("/history")
    public ResponseEntity<List<LeaveHistoryByDateResponse>>getHistoryByDate(@RequestParam("date") String date, @AuthenticationPrincipal String userId) {
        log.debug("[LeaveController] GET /api/leave/history");
        List<LeaveHistoryByDateResponse> dateResponses = new LinkedList<>();

        List<LeaveHistory> leaveHistories = leaveService.getHistoryListByDate(date, userId);

        for (LeaveHistory history : leaveHistories)
        {
            dateResponses.add(new LeaveHistoryByDateResponse(history));
        }

        return ResponseEntity.ok(dateResponses);
    }

    @PostMapping("/delete")
    public ResponseEntity<?> deleteHistory(@RequestBody DeleteHistoryRequest request, @AuthenticationPrincipal String userId){
        log.debug("[LeaveController] DELETE /api/leave/delete");
        request.setUserId(userId);
        leaveService.deleteHistory(request);
        return ResponseEntity.ok("");
    }
    
}
