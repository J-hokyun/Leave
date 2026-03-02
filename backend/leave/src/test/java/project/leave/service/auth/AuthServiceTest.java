package project.leave.service.auth;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;
import project.leave.dto.auth.JoinRequest;
import project.leave.dto.auth.LoginRequest;
import project.leave.global.error.exception.DuplicateEmailException;
import project.leave.global.error.exception.PasswordInvalidException;
import project.leave.global.error.exception.PasswordMismatchException;
import project.leave.global.error.exception.UserNotExistsException;
import project.leave.repository.user.UserRepository;

@SpringBootTest // 실제 스프링 컨테이너를 띄워 모든 Bean을 주입받음
@Transactional  // 테스트 완료 후 DB에 반영된 내용을 자동으로 Rollback 함
class AuthServiceTest {

    @Autowired
    private AuthService authService;

    @Autowired
    private UserRepository userRepository;

    @Test
    @DisplayName("회원가입 성공 테스트 (실제 DB 연동)")
    void userJoin_Success() {
        // given
        String email = "real_db_test@test.com";
        JoinRequest request = JoinRequest.builder()
                                .email(email)
                                .password("password123")
                                .passwordConfirm("password123")
                                .leaveAccount(15)
                                .build();
    
        // when
        authService.userJoin(request);

        // 실제로 DB에 저장되었는지 Repository로 직접 조회 확인
        assertTrue(userRepository.existsByEmail(email));
    }

    @Test
    @DisplayName("비밀번호 불일치 시 예외 발생 테스트")
    void userJoin_PasswordMismatch() {
        // given
        JoinRequest request = JoinRequest.builder()
                .email("mismatch@test.com")
                .password("password123")
                .passwordConfirm("wrong_password")
                .build();

        // when & then
        assertThrows(PasswordMismatchException.class, () -> {
            authService.userJoin(request);
        });
    }

    @Test
    @DisplayName("이메일 중복 시 실제 DB 제약조건 확인")
    void userJoin_DuplicateEmail() {
        // given
        String email = "duplicate@test.com";
        JoinRequest request1 = JoinRequest.builder()
                                .email(email)
                                .password("password123")
                                .passwordConfirm("password123")
                                .leaveAccount(15)
                                .build();
        authService.userJoin(request1);

        JoinRequest request2 = JoinRequest.builder()
                                .email(email)
                                .password("password123")
                                .passwordConfirm("password123")
                                .leaveAccount(15)
                                .build();                                
        // when & then
        // 서비스에서 작성한 중복 예외(RuntimeException 등)가 발생하는지 확인
        assertThrows(DuplicateEmailException.class, () -> {
            authService.userJoin(request2);
        });
    }

    @Test
    @DisplayName("로그인 정상 동작 테스트")
    void userLogin_Scccess(){

        // given
        String testEmail = "real_db_test@test.com";
        String testPassword = "password123";
        JoinRequest request = JoinRequest.builder()
                                .email(testEmail)
                                .password(testPassword)
                                .passwordConfirm(testPassword)
                                .leaveAccount(15)
                                .build();
        LoginRequest loginRequest = LoginRequest.builder()
                                    .email(testEmail)
                                    .password(testPassword)
                                    .build();

        // when
        authService.userJoin(request);

        assertDoesNotThrow(() -> authService.userLogin(loginRequest));
    }

    @Test
    @DisplayName("존재하지 않는 이메일 테스트")
    void userLoginFali_ByEmailIsNotExists(){

        // given
        String testEmail = "real_db_test@test.com";
        String notExistsEmail = "real_db_test@test.com1";
        String testPassword = "password123";

        JoinRequest request = JoinRequest.builder()
                                .email(testEmail)
                                .password(testPassword)
                                .passwordConfirm(testPassword)
                                .leaveAccount(15)
                                .build();
        LoginRequest loginRequest = LoginRequest.builder()
                                    .email(notExistsEmail)
                                    .password(testPassword)
                                    .build();

        // when
        authService.userJoin(request);

        assertThrows(UserNotExistsException.class,() -> {
            authService.userLogin(loginRequest);
        });
    }

    @Test
    @DisplayName("비밀번호 미일치 테스트")
    void userLoginFali_ByPasswordInvalid(){

        // given
        String testEmail = "real_db_test@test.com";
        String testPassword = "password123";
        String invalidPassword = "password1234";

        JoinRequest request = JoinRequest.builder()
                                .email(testEmail)
                                .password(testPassword)
                                .passwordConfirm(testPassword)
                                .leaveAccount(15)
                                .build();

        LoginRequest loginRequest = LoginRequest.builder()
                                    .email(testEmail)
                                    .password(invalidPassword)
                                    .build();

        // when
        authService.userJoin(request);

        assertThrows(PasswordInvalidException.class, () -> {
            authService.userLogin(loginRequest);
        });
    }
}