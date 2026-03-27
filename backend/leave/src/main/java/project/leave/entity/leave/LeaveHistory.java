package project.leave.entity.leave;

import java.time.LocalDateTime;
import java.util.UUID;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import project.leave.dto.leave.LeaveHistoryRequest;


@Entity
@Table(name = "tb_leave_history")
@Getter 
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LeaveHistory {

    @Id
    @Column(name = "id", length = 30)
    private String id;

    @Column(nullable = false, unique = true, columnDefinition = "uuid")
    private UUID uuid;

    @Column(name = "user_id", nullable = false, length = 30)
    private String userId;

    @Column(name = "date", nullable = false, length = 8)
    private String date;

    @Column(name = "leave_reason", length = 255)
    private String leaveReason;

    @Column(name = "leave_type_code", nullable = false, length = 1)
    private String leaveTypeCode;

    @Column(name = "parent_id", nullable = false, length = 30)
    private String parentId;
    
    @Column(name = "is_holiday", nullable = false, length = 1)
    private String isHoliday;
    
    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "created_by", length = 30)
    private String createdBy;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @Column(name = "updated_by", length = 30)
    private String updatedBy;
    
    public LeaveHistory(LeaveHistoryRequest leaveRecordRequest)
    {
        this.leaveReason = leaveRecordRequest.getLeaveReason();
        this.leaveTypeCode = leaveRecordRequest.getLeaveTypeCode();
    }
}