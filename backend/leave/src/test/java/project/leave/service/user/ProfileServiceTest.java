package project.leave.service.user;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

import java.text.DecimalFormat;
import java.time.LocalDateTime;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import jakarta.transaction.Transactional;
import project.leave.dto.auth.LoginRequest;
import project.leave.dto.leave.LeaveHistoryRequest;
import project.leave.dto.user.CountChangeRequest;
import project.leave.dto.user.IsIncludeHolidayChangeRequest;
import project.leave.dto.user.PasswordChangeRequest;
import project.leave.entity.user.UserLeaveTot;
import project.leave.global.error.exception.PasswordInvalidException;
import project.leave.repository.user.UserLeaveTotRepository;
import project.leave.service.auth.AuthService;
import project.leave.service.leave.LeaveService;

@SpringBootTest 
@Transactional  
public class ProfileServiceTest {
    @Autowired
    private ProfileService profileService;
    
    @Autowired
    private AuthService authService;

    @Autowired
    private LeaveService leaveService;

    @Autowired
    private UserLeaveTotRepository leaveTotRepository;

    private String testUserId = "user2026032800003";
    private String testPassword = "password3#";
    private String testUserEmail = "test@naver.com";
    private String curYear = String.valueOf( LocalDateTime.now().getYear());
    DecimalFormat df = new DecimalFormat("###.##");

    @Test
    @DisplayName("비밀번호 인증 테스트")
    void validPassword()
    {
        assertDoesNotThrow(() -> profileService.validPassword(testPassword, testUserId));
    }

    @Test
    @DisplayName("비밀번호 변경 테스트")
    void updatePasswordTest()
    {
        String newPassword = "newpassword123!!";
        String newPasswordConfirm = "newpassword123!!";

        PasswordChangeRequest passwordChangeRequest = PasswordChangeRequest.builder()
        .password(newPassword)
        .passwordConfirm(newPasswordConfirm)
        .build();
        
        profileService.changePassword(passwordChangeRequest, testUserId);

        LoginRequest loginRequest = LoginRequest.builder().email(testUserEmail).password(newPassword).build();
        assertDoesNotThrow(() ->  authService.userLogin(loginRequest));
    }

    @Test
    @DisplayName("비밀번호 변경 후 과거 패스워드 로그인 테스트")
    void oldPasswordShouldFailAfterUpdateTest()
    {
        String newPassword = "newpassword123!!";
        String newPasswordConfirm = "newpassword123!!";

        PasswordChangeRequest passwordChangeRequest = PasswordChangeRequest.builder()
        .password(newPassword)
        .passwordConfirm(newPasswordConfirm)
        .build();
        
        profileService.changePassword(passwordChangeRequest, testUserId);

        LoginRequest loginRequest = LoginRequest.builder().email(testUserEmail).password(testPassword).build();
        assertThrows(PasswordInvalidException.class,() -> { authService.userLogin(loginRequest);  });
    }

    @Test
    @DisplayName("연차 갯수 변경 테스트")
    void updateLeaveTotalCountTest()
    {
        int newLeaveCount = 16;
        CountChangeRequest countChangeRequest = CountChangeRequest.builder().count(newLeaveCount).build();
        
        profileService.changeLeaveCount(countChangeRequest, testUserId);

        UserLeaveTot userLeaveTot = leaveTotRepository.findByUserIdAndYear(testUserId, curYear);

        assertEquals(16, userLeaveTot.getTotalLeaveCount());
    }

    @Test
    @DisplayName("연차 공휴일 여부 변경 테스트")
    void updateIsCludeHolidayTest()
    {
        
        String holiday1 = curYear + "0501";
        String holiday2 = curYear + "0505";

        LeaveHistoryRequest historyRequest1 = LeaveHistoryRequest.builder()
        .startDate(holiday1)
        .endDate(holiday1)
        .leaveTypeCode("0")
        .leaveReason("휴가")
        .build();

        LeaveHistoryRequest historyRequest2 = LeaveHistoryRequest.builder()
        .startDate(holiday2)
        .endDate(holiday2)
        .leaveTypeCode("0")
        .leaveReason("휴가")
        .build();

        leaveService.saveLeaveHisory(historyRequest1, testUserId);
        leaveService.saveLeaveHisory(historyRequest2, testUserId);

        String beforeUsed = df.format(leaveService.calUsedLeave(testUserId)); // 공휴일 여부 변경전 연차 사용 갯수.

        IsIncludeHolidayChangeRequest isIncludeHolidayChangeRequest = IsIncludeHolidayChangeRequest.builder()
        .isIncludeHoliday("Y")
        .build();

        profileService.changeIsIncludeHoliday(isIncludeHolidayChangeRequest, testUserId); // 연차 공휴일 여부 Y 업데이트

        String afterUsed = df.format(leaveService.calUsedLeave(testUserId)); // 공휴일 여부 변경후 연차 사용 갯수.

        assertEquals("0", beforeUsed);
        assertEquals("2", afterUsed);
    
    }




}
