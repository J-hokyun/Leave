package project.leave.controller.user;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import project.leave.dto.user.ProfileResponse;
import project.leave.dto.user.CountChangeRequest;
import project.leave.dto.user.PasswordChangeRequest;
import project.leave.dto.user.PasswordValidRequest;
import project.leave.entity.user.User;
import project.leave.service.user.ProfileService;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.GetMapping;



@RestController
@Slf4j
@RequiredArgsConstructor
@RequestMapping("/api/user")
public class ProfileController {

    private final ProfileService profileService;

    @PostMapping("/valid")
    public ResponseEntity<?> validPasswordController(@RequestBody PasswordValidRequest passwordValidRequest, @AuthenticationPrincipal String userId) {
        log.debug("[ProfileController] POST /api/user/valid ");
        profileService.validPassword(passwordValidRequest.getPassword(), userId);
        return ResponseEntity.ok("");
    }

    @GetMapping("/profile")
    public ResponseEntity<ProfileResponse> getUserProfileController(@AuthenticationPrincipal String userId) {
        log.debug("[ProfileController] GET /api/user/profile ");

        User user = profileService.getUserProfile(userId);
        ProfileResponse profileResponse = ProfileResponse.builder().email(user.getEmail()).count(user.getTotalLeaveCount()).build();
        return ResponseEntity.ok(profileResponse);
    }

    @PostMapping("/profile/password")
    public ResponseEntity<?> passwordChangeController(@RequestBody PasswordChangeRequest passwordChangeRequest, @AuthenticationPrincipal String userId) {
        log.debug("[ProfileController] POST /api/user/password");
        profileService.changePassword(passwordChangeRequest, userId);
        return ResponseEntity.ok("");
    }


    @PostMapping("/profile/count")
    public ResponseEntity<?> leaveCountController(@RequestBody CountChangeRequest countChangeRequest, @AuthenticationPrincipal String userId) {
        log.debug("[ProfileController] POST /api/profile/count");
        profileService.changeLeaveCount(countChangeRequest, userId);
        return ResponseEntity.ok("");
    }

    @PostMapping("/profile/delete")
    public ResponseEntity<?> deleteUserInformController(@AuthenticationPrincipal String userId) {
        log.debug("[ProfileController] POST /api/profile/delete");
        profileService.deleteUserInform(userId);
        
        return ResponseEntity.ok("");
    }
    
    
    
}
