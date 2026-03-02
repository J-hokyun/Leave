package project.leave.controller;

import java.util.ArrayList;
import java.util.List;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import project.leave.dto.UserResponse;
import project.leave.entity.user.User;
import project.leave.service.user.UserService;


@RestController
@RequiredArgsConstructor
@Slf4j
public class HomeController {
    
    private final UserService userService;


    @GetMapping("/")
    public List<User> getUser() {
        log.debug("[HomeController] getAllUser start ");
        return userService.getAllUsers();
    }

    @GetMapping("/api/user")
    public List<UserResponse> getAbleUser(@AuthenticationPrincipal String userId) {
        log.debug("[HomeController] getAbleUser start userId : {}", userId);

        List<UserResponse> userResponses = new ArrayList<>();
        for (User user : userService.getAbleUsers())
        {
            userResponses.add(new UserResponse(user));
        }
        return userResponses;
    }
    

}
