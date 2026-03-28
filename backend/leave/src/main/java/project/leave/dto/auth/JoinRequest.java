package project.leave.dto.auth;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class JoinRequest {
    private String email;
    private String passwordConfirm;
    private String password;
    private int leaveAccount;
    private boolean includeHoliday;
}
