package project.leave.entity.leave;

import lombok.*;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.LocalDateTime;

@Entity
@Table(name = "tb_leave_detail")
@Getter
@Setter
@NoArgsConstructor(access = AccessLevel.PROTECTED) // JPA를 위한 기본 생성자
@AllArgsConstructor
@Builder
public class LeaveDetail {
    @Id
    @Column(name = "id", length = 30)
    private String id;

    @Column(name = "user_id", length = 30, nullable = false)
    private String userId;

    @Column(name = "leave_type_code", length = 1, nullable = false)
    private String leaveTypeCode;

    @Builder.Default
    @Column(name = "used_count")
    private int usedCount = 0;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "created_by", length = 30, updatable = false)
    private String createdBy;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @Column(name = "updated_by", length = 30)
    private String updatedBy;


    
    public void addUsedCount(int count, String userId)
    {
        this.usedCount += count;
        this.updatedBy = userId;
        this.updatedAt = LocalDateTime.now();
    }
}
