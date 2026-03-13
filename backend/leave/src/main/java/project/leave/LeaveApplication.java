package project.leave;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class LeaveApplication {

	public static void main(String[] args) {
		SpringApplication.run(LeaveApplication.class, args);
	}

}
