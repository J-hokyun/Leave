package project.leave.service.leave;

import java.util.List;

import org.springframework.stereotype.Service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import project.leave.repository.leave.HolidayRepository;

@Service
@Slf4j
@RequiredArgsConstructor
public class HolidayService {
    private final HolidayRepository holidayRepository;

    public List<String> getHolidaysInMonth(String month){
        log.debug("[HolidayService] start getHolidaysInMonth month : {}", month);
        return holidayRepository.findAllHolidaysByMonth(month);
    }

    public String getHolidayNameByDate(String date){
        log.debug("[HolidayService] start get holiday name by date : {}", date);
        return holidayRepository.findHolidayNameByDate(date).orElse("");
    }
    
}
