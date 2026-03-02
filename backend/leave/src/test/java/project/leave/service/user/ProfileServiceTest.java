package project.leave.service.user;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertThrows;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import jakarta.transaction.Transactional;
import project.leave.dto.auth.LoginRequest;
import project.leave.dto.user.CountChangeRequest;
import project.leave.dto.user.PasswordChangeRequest;
import project.leave.global.error.exception.PasswordInvalidException;
import project.leave.service.auth.AuthService;

@SpringBootTest 
@Transactional  
public class ProfileServiceTest {
    @Autowired
    private ProfileService profileService;
    
    @Autowired
    private AuthService authService;

    private String testUserId = "user2026021500002";
    private String testPassword = "12345678";
    private String testUserEmail = "sptest@naver.com";

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

    }




}
