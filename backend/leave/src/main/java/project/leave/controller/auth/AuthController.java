package project.leave.controller.auth;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import project.leave.dto.auth.JoinRequest;
import project.leave.dto.auth.LoginRequest;
import project.leave.dto.global.TokenResponse;
import project.leave.global.jwt.JwtTokenProvider;
import project.leave.service.auth.AuthService;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;


@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@Slf4j
public class AuthController {

    private final AuthService authService;
    private final JwtTokenProvider jwtTokenProvider;

    @PostMapping("/login")
    public ResponseEntity<?> postLoginController(@RequestBody LoginRequest loginRequest) {
        log.debug("[AuthController] /login controller start ");
        log.debug("email : {}, password : {}", loginRequest.getEmail(), loginRequest.getPassword());
        String userId = authService.userLogin(loginRequest);
        
        String token = jwtTokenProvider.createToken(userId);

        return ResponseEntity.ok(new TokenResponse(token));
    }

    @PostMapping("/logout")
    public ResponseEntity<?> postLogoutController(HttpServletRequest request) {
        log.debug("[AuthController] /logout controller start ");
        return ResponseEntity.ok("");
    }
    
    

    @PostMapping("/join")
    public ResponseEntity<?> postJoinController(@RequestBody JoinRequest joinRequest) {
        log.debug("[AuthController] /join controller start");

        authService.userJoin(joinRequest);

        return ResponseEntity.ok("회원가입에 성공하였습니다.");

    }
    

}
