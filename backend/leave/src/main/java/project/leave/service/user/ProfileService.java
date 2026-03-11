package project.leave.service.user;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import project.leave.dto.user.CountChangeRequest;
import project.leave.dto.user.PasswordChangeRequest;
import project.leave.entity.user.User;
import project.leave.global.error.exception.PasswordInvalidException;
import project.leave.global.error.exception.PasswordMismatchException;
import project.leave.global.error.exception.UserNotExistsException;
import project.leave.repository.leave.LeaveDetailRepository;
import project.leave.repository.leave.LeaveHistoryRepository;
import project.leave.repository.user.UserRepository;

@Service
@Slf4j
@RequiredArgsConstructor
public class ProfileService {
    private final UserRepository userRepository;
    private final LeaveDetailRepository leaveDetailRepository;
    private final LeaveHistoryRepository leaveHistoryRepository;
    PasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    public User getUserProfile(String userId)
    {
        log.debug("[ProfileService] start getUserProfile ");
        User user = userRepository.findByUserId(userId);
        if (user == null)
        {
            log.debug("[AuthService] email is not exists");
            throw new UserNotExistsException("존재하지 않는 사용자입니다.");
        }
        return user;
    }

    /* 개인정보 변경 시, 패스워드 검증 로직 */
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
    }

    /* 연차 갯수 변경 로직 */
    @Transactional
    public void changeLeaveCount(CountChangeRequest countChangeRequest, String userId)
    {
        log.debug("[ProfileService] start update Leave Count");
        User user = userRepository.findByUserId(userId);
        if (user == null)
        {
            log.debug("[ProfileService] user is not exists");
            throw new UserNotExistsException("존재하지 않는 사용자입니다.");
        }

        user.setTotalLeaveCount(countChangeRequest.getCount());
    }
    
    @Transactional
    public void deleteUserInform(String userId){
        log.debug("[ProfileService] start delete user inform");
        
        if (leaveDetailRepository.findAllByUserId(userId).orElse(null) != null)
        {
            leaveDetailRepository.deleteByuserId(userId);
        }

        if (leaveHistoryRepository.findAllByUserId(userId).orElse(null) != null)
        {
            leaveHistoryRepository.deleteByuserId(userId);
        }
        
        userRepository.deleteByuserId(userId);
    }


}
