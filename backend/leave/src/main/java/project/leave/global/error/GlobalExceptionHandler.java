package project.leave.global.error;

import java.time.LocalDateTime;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import lombok.extern.slf4j.Slf4j;
import project.leave.dto.global.ErrorResponse;
import project.leave.global.error.exception.DuplicateEmailException;
import project.leave.global.error.exception.LeaveCountOverException;
import project.leave.global.error.exception.LeaveDateDupliaceException;
import project.leave.global.error.exception.PasswordInvalidException;
import project.leave.global.error.exception.PasswordMismatchException;
import project.leave.global.error.exception.ResourcesNotFoundException;
import project.leave.global.error.exception.UserNotExistsException;

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    // 회원가입시 비밀번호 & 비밀번호 확인 미일치 (400 Bad Request)
    @ExceptionHandler(PasswordMismatchException.class)
    public ResponseEntity<ErrorResponse> handlePasswordMismatch(PasswordMismatchException e) {
        log.info("[GlobalExceptionHandler] password mismatch: {}", e.getMessage());
        return buildResponse(HttpStatus.BAD_REQUEST, e.getMessage());
    }

    // 이메일 중복 예외
    @ExceptionHandler(DuplicateEmailException.class)
    public ResponseEntity<ErrorResponse> handleDuplicateEmail(DuplicateEmailException e) {
        log.info("[GlobalExceptionHandler] duplicate email: {}", e.getMessage());
        return buildResponse(HttpStatus.CONFLICT,  e.getMessage());
    }

    // 로그인 시 비밀번호 검증 미일치
    @ExceptionHandler(PasswordInvalidException.class)
    public ResponseEntity<ErrorResponse> handlePasswordInvalid(PasswordInvalidException e) {
        log.info("[GlobalExceptionHandler] password invalid: {}", e.getMessage());
        return buildResponse(HttpStatus.BAD_REQUEST,  e.getMessage());
    }

    // 자료 없는 예외
    @ExceptionHandler(ResourcesNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleResourcesNotFound(ResourcesNotFoundException e) {
        log.info("[GlobalExceptionHandler] Resource NotFound: {}", e.getMessage());
        return buildResponse(HttpStatus.NOT_FOUND,  e.getMessage());
    }

    // 유저가 없는 예외
    @ExceptionHandler(UserNotExistsException.class)
    public ResponseEntity<ErrorResponse> handleUserNotExists(UserNotExistsException e) {
        log.info("[GlobalExceptionHandler] User Not Exists: {}", e.getMessage());
        return buildResponse(HttpStatus.CONFLICT,  e.getMessage());
    }    

    // DB 제약 조건 위반 (예: 유니크 키 중복 등)
    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<ErrorResponse> handleDataIntegrity(DataIntegrityViolationException e) {
        log.error("Database Error: {}", e.getMessage());
        return buildResponse(HttpStatus.INTERNAL_SERVER_ERROR, "이미 존재하는 데이터입니다.");
    }

    // 연차 갯수 오버 에러
    @ExceptionHandler(LeaveCountOverException.class)
    public ResponseEntity<ErrorResponse> handleLeaveCountOver(LeaveCountOverException e) {
        log.error("Database Error: {}", e.getMessage());
        return buildResponse(HttpStatus.CONFLICT, e.getMessage());
    }

    // 휴가 날짜 중복 에러
    @ExceptionHandler(LeaveDateDupliaceException.class)
    public ResponseEntity<ErrorResponse> handleLeaveDateDuplicate(LeaveDateDupliaceException e) {
        log.info("leave date duplicate Error: {}", e.getMessage());
        return buildResponse(HttpStatus.BAD_REQUEST, e.getMessage());
    }    

    // 공통 응답 생성 메서드
    private ResponseEntity<ErrorResponse> buildResponse(HttpStatus status, String message) {
        ErrorResponse response = ErrorResponse.builder()
                .status(status.value())
                .message(message)
                .timestamp(LocalDateTime.now())
                .build();
        return new ResponseEntity<>(response, status);
    }
}