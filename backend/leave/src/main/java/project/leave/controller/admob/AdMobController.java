package project.leave.controller.admob;

import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class AdMobController {

    @GetMapping(value = "/app-ads.txt", produces = MediaType.TEXT_PLAIN_VALUE)
    public String getAppAdsTxt() {
        return "google.com, pub-8528721677066882, DIRECT, f08c47fec0942fa0";
    }
}