package project.leave.service.auth;

import java.time.LocalDateTime;
import java.util.UUID;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import project.leave.dto.auth.JoinRequest;
import project.leave.dto.auth.LoginRequest;
import project.leave.entity.user.User;
import project.leave.entity.user.UserLeaveTot;
import project.leave.global.error.exception.DuplicateEmailException;
import project.leave.global.error.exception.PasswordInvalidException;
import project.leave.global.error.exception.PasswordMismatchException;
import project.leave.global.error.exception.UserNotExistsException;
import project.leave.repository.user.UserLeaveTotRepository;
import project.leave.repository.user.UserRepository;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthService {
    
    private final UserRepository userRepository;
    private final UserLeaveTotRepository leaveTotRepository;

    PasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    /* 로그인 서비스 */
    @Transactional
    public String userLogin(LoginRequest loginRequest)
    {
        log.debug("[AuthService] userLogin is start");

        User user = userRepository.findByEmail(loginRequest.getEmail());
        if (user == null)
        {
            log.debug("[AuthService] email is not exists");
            throw new UserNotExistsException("존재하지 않는 이메일입니다.");
        }
        if (!passwordEncoder.matches(loginRequest.getPassword(), user.getPassword()))
        {
            log.debug("[AuthService] password is invalid");
            throw new PasswordInvalidException("비밀번호가 일치하지 않습니다.");            
        }

        return user.getId();
    }

    /* 회원가입 서비스 */
    @Transactional
    public void userJoin(JoinRequest joinRequest)
    {
        log.debug("[AuthService] userJoin is start");

        if (!joinRequest.getPassword().equals(joinRequest.getPasswordConfirm()))
        {
            log.debug("[AuthService] passwordEncode password is not same");
            throw new PasswordMismatchException("비밀번호가 일치하지 않습니다");
        }

        if (userRepository.existsByEmail(joinRequest.getEmail()))
        {
            log.debug("[AuthService] email duplicate error");
            throw new DuplicateEmailException("이미 존재하는 이메일 입니다.");
        }

        String newUserId = generateUserId();
        User newUser = User.builder()
                        .id(newUserId)
                        .uuid(generateUuid())
                        .email(joinRequest.getEmail())
                        .password(passwordEncoder.encode(joinRequest.getPassword()))
                        .isActive(1)
                        .createdBy(newUserId)
                        .createdAt(LocalDateTime.now())
                        .updatedBy(newUserId)
                        .updatedAt(LocalDateTime.now())
                        .build();
        
        userRepository.save(newUser);

        UserLeaveTot newTot = UserLeaveTot.builder()
                        .id(leaveTotRepository.findNewTotId())
                        .uuid(generateUuid())
                        .userId(newUserId)
                        .year(String.valueOf(LocalDateTime.now().getYear()))
                        .totalLeaveCount(joinRequest.getLeaveAccount())
                        .createdBy(newUserId)
                        .createdAt(LocalDateTime.now())
                        .updatedBy(newUserId)
                        .updatedAt(LocalDateTime.now())
                        .build();
        leaveTotRepository.save(newTot);
    }

    /* userId DB로부터 조회 */
    private String generateUserId()
    {   log.debug("[AuthService] generateUserId is start");
        return userRepository.getNewUserId();
    }

    private UUID generateUuid()
    {
        log.debug("[AuthService] generateUuid is start");
        return UUID.randomUUID();
    }


}
