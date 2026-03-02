package project.leave.dto.leave;

import java.util.UUID;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import project.leave.entity.leave.LeaveHistory;

/* 캘린더 화면(해당 날짜에 존재하는 연차 내역) 하단, 응답 dto */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LeaveHistoryByDateResponse {
    private UUID uuid;
    private String leaveTypeCode;
    private String leaveTypeName;
    private String leaveReason;

    public LeaveHistoryByDateResponse(LeaveHistory leaveHistory)
    {
        this.uuid = leaveHistory.getUuid();
        this.leaveTypeCode = leaveHistory.getLeaveTypeCode();
        this.leaveReason = leaveHistory.getLeaveReason();

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
