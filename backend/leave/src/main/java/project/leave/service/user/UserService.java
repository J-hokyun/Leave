package project.leave.service.user;

import java.util.List;
import org.springframework.stereotype.Service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import project.leave.entity.user.User;
import project.leave.repository.user.UserRepository;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserService {

    private final UserRepository userRepository;

    public List<User> getAllUsers()
    {
        log.debug("[UserService] getAllUsers start");
        return userRepository.findAll();
    }

    public List<User> getAbleUsers()
    {
        log.debug("[UserService] getAbleUsers start");
        return userRepository.findAbleUser();
    }

}
