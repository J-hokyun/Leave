package project.leave.dto.leave;

import java.util.UUID;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import project.leave.entity.leave.LeaveHistory;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class YearlyListResponse {
    private UUID uuid;
    private String date;
    private String leaveTypeCode;
    private String leaveTypeName;
    private String leaveReason;

    public YearlyListResponse(LeaveHistory leaveHistory){
        this.uuid = leaveHistory.getUuid();
        this.leaveTypeCode = leaveHistory.getLeaveTypeCode();
        this.date = leaveHistory.getDate();
        
        String rawReason = leaveHistory.getLeaveReason();
        if (rawReason == null || rawReason.trim().isEmpty()) {
            this.leaveReason = "사유없음";
        } else {
            this.leaveReason = rawReason;
        }
        if (leaveHistory.getLeaveTypeCode().equals("0"))
        {
            this.leaveTypeName = "연차";
        }else if(leaveHistory.getLeaveTypeCode().equals("1"))
        {
            this.leaveTypeName = "반차";
        }else{
            this.leaveTypeName = "반반차";
        }
    }
}
