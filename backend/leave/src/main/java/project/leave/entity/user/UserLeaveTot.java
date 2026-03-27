package project.leave.entity.user;

import java.time.LocalDateTime;
import java.util.UUID;

import org.hibernate.annotations.ColumnDefault;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;


import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Entity
@Table(name = "tb_user_leave_tot")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@ToString
public class UserLeaveTot {

    @Id // 단일 PK로 변경
    @Column(length = 30)
    private String id; 

    @Column(nullable = false, unique = true, columnDefinition = "uuid")
    private UUID uuid;

    @Column(name = "user_id", nullable = false, length = 30)
    private String userId;

    @Column(nullable = false, length = 4)
    private String year;

    @Column(name = "total_leave_count")
    @ColumnDefault("0")
    private int totalLeaveCount;

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
}
    

