package project.leave.controller.leave;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import project.leave.dto.leave.HolidayInMonthRequest;
import project.leave.service.leave.HolidayService;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;


@RestController
@Slf4j
@RequiredArgsConstructor
@RequestMapping("/api/holiday")
public class HolidayController {
    private final HolidayService holidayService;

    @GetMapping("/month")
    public ResponseEntity<?> getHolidayInMonth(@ModelAttribute HolidayInMonthRequest request) {
        log.debug("[] GET /api/holiday/month");
        return ResponseEntity.ok(holidayService.getHolidaysInMonth(request.getMonth()));
    }
    
    
}
