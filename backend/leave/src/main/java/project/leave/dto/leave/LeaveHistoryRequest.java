package project.leave.dto.leave;

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
public class LeaveHistoryRequest {
    private String startDate;
    private String endDate;
    private String leaveTypeCode;
    private String leaveReason;            

}
