package project.leave.global.config;

import lombok.RequiredArgsConstructor;
import project.leave.global.jwt.JwtAuthenticationFilter;
import project.leave.global.jwt.JwtTokenProvider;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtTokenProvider jwtTokenProvider;

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            // 1. CSRF 비활성화 (앱 환경에서는 세션을 쓰지 않으므로 보통 비활성화함)
            .csrf(csrf -> csrf.disable())

            // 2. 세션을 사용하지 않도록 설정 (Stateless)
            .sessionManagement(session -> 
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            )

            // 3. API 접근 권한 설정
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/auth/login", "/api/auth/join").permitAll() // 로그인, 회원가입은 누구나 접근 가능
                .anyRequest().authenticated() // 그 외 모든 요청은 인증 필요
            )

            // 4. JWT 필터를 UsernamePasswordAuthenticationFilter 이전에 끼워넣기
            .addFilterBefore(new JwtAuthenticationFilter(jwtTokenProvider), 
                                UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}