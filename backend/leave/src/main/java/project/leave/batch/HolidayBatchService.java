package project.leave.batch;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import project.leave.entity.leave.Holiday;
import project.leave.repository.leave.HolidayRepository;

import java.net.URI;
import java.time.LocalDate;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

@Service
@RequiredArgsConstructor
@Slf4j
public class HolidayBatchService {

    private final HolidayRepository holidayRepository;
    private final ObjectMapper objectMapper; // Spring이 주입해주는 기본 ObjectMapper 사용

    @Value("${holiday.api.service-key}")
    private String serviceKey;

    @Value("${holiday.api.url}")
    private String apiUrl;

    @Scheduled(cron = "0 0 1 * * *")
    @Transactional
    public void runHolidayBatch() {
        log.debug(">>>> [HolidayBatch] 공휴일 동기화 시작");
        RestTemplate restTemplate = new RestTemplate(); 
        int currentYear = LocalDate.now().getYear();
        String year = String.valueOf(currentYear);

        for (int month = 1; month <= 12; month++) {
            String monthStr = String.format("%02d", month);
            try {
                String urlString = apiUrl + "?serviceKey=" + serviceKey +
                        "&solYear=" + year +
                        "&solMonth=" + monthStr +
                        "&_type=json";

                URI uri = new URI(urlString);
                String jsonResponse = restTemplate.getForObject(uri, String.class);
                JsonNode root = objectMapper.readTree(jsonResponse);
                JsonNode itemsNode = root.path("response").path("body").path("items");

                if (itemsNode.isTextual() || itemsNode.isEmpty()) {
                    log.debug("{}월은 공휴일이 없습니다.", monthStr);
                    continue;
                }

                JsonNode itemNode = itemsNode.path("item");
                if (itemNode.isArray()) {
                    for (JsonNode node : itemNode) {
                        saveHoliday(node);
                    }
                } else if (itemNode.isObject()) {
                    saveHoliday(itemNode);
                }

            } catch (Exception e) {
                log.error("{}월 데이터 처리 중 에러 발생: {}", monthStr, e.getMessage());
            }
        }
        log.info(">>>> [HolidayBatch] 동기화 종료");
    }

    private void saveHoliday(JsonNode node) {
        String isHoliday = node.path("isHoliday").asText();
        String locdate = node.path("locdate").asText();
        String dateName = node.path("dateName").asText();

        if ("Y".equals(isHoliday) && !holidayRepository.existsById(locdate)) {
            Holiday holiday = Holiday.builder()
                    .date(locdate)
                    .dateName(dateName)
                    .build();
            holidayRepository.save(holiday);
            log.info("Successfully Saved: {} ({})", locdate, dateName);
        }
    }
}