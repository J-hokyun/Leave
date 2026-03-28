package project.leave.service.user;

import java.time.LocalDate;
import java.time.LocalDateTime;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import project.leave.dto.user.CountChangeRequest;
import project.leave.dto.user.PasswordChangeRequest;
import project.leave.dto.user.ProfileResponse;
import project.leave.entity.user.User;
import project.leave.entity.user.UserLeaveTot;
import project.leave.global.error.exception.PasswordInvalidException;
import project.leave.global.error.exception.PasswordMismatchException;
import project.leave.global.error.exception.UserNotExistsException;

import project.leave.repository.leave.LeaveHistoryRepository;
import project.leave.repository.user.UserLeaveTotRepository;
import project.leave.repository.user.UserRepository;

@Service
@Slf4j
@RequiredArgsConstructor
public class ProfileService {
    private final UserRepository userRepository;
    private final UserLeaveTotRepository leaveTotRepository;
    private final LeaveHistoryRepository leaveHistoryRepository;

    PasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
    String curYear = String.valueOf(LocalDateTime.now().getYear());

    public ProfileResponse getUserProfile(String userId)
    {
        log.debug("[ProfileService] start getUserProfile ");
        String email = userRepository.findByUserId(userId).getEmail();
        int userLeavetot = leaveTotRepository.findLeaveCountByUserIdAndYear(userId, curYear);

        ProfileResponse response = ProfileResponse.builder()
                                    .email(email)
                                    .count(userLeavetot).build();
        return response;
    }

    /* 비밀번호 변경 시, 패스워드 검증 로직 */
    public void validPassword(String password, String userId)
    {
        log.debug("[ProfileService] start valid user password");
        String trimUserId = userId.trim();
        User user = userRepository.findByUserId(trimUserId);

        if (user == null)
        {
            log.debug("[AuthService] email is not exists");
            throw new UserNotExistsException("존재하지 않는 사용자입니다.");
        }
        if (!passwordEncoder.matches(password, user.getPassword()))
        {
            log.debug("[AuthService] password is invalid");
            throw new PasswordInvalidException("비밀번호가 일치하지 않습니다.");            
        }
    }

    /* 비밀번호 변경 로직 */
    @Transactional
    public void changePassword(PasswordChangeRequest passwordChangeRequest, String userId)
    {
        log.debug("[ProfileService] start update password");

        if (!passwordChangeRequest.getPassword().equals(passwordChangeRequest.getPasswordConfirm()))
        {
            log.debug("[AuthService] passwordEncode password is not same");
            throw new PasswordMismatchException("비밀번호가 일치하지 않습니다");
        }

        User user = userRepository.findByUserId(userId);
        if (user == null)
        {
            log.debug("[AuthService] user is not exists");
            throw new UserNotExistsException("존재하지 않는 사용자입니다.");
        }
        
        String encodeNewPassword = passwordEncoder.encode(passwordChangeRequest.getPassword());
        user.setPassword(encodeNewPassword);
        user.setUpdatedAt(LocalDateTime.now());
        user.setUpdatedBy(userId);
    }

    /* 연차 갯수 변경 로직 */
    @Transactional
    public void changeLeaveCount(CountChangeRequest countChangeRequest, String userId)
    {
        log.debug("[ProfileService] start update Leave Count");
        String year = String.valueOf(LocalDate.now().getYear());
        UserLeaveTot leaveTot = leaveTotRepository.findByUserIdAndYear(userId, year);
        leaveTot.setTotalLeaveCount(countChangeRequest.getCount());
        leaveTot.setUpdatedAt(LocalDateTime.now());
        leaveTot.setUpdatedBy(userId);
    }
    
    @Transactional
    public void deleteUserInform(String userId){
        log.debug("[ProfileService] start delete user inform");
        if (leaveHistoryRepository.findAllByUserId(userId).orElse(null) != null)
        {
            leaveHistoryRepository.deleteByuserId(userId);
        }
        leaveTotRepository.deleteAllByUserId(userId);
        userRepository.deleteByuserId(userId);
    }


}
