package project.leave.entity.user;

import jakarta.persistence.*;
import lombok.*;
import project.leave.dto.auth.JoinRequest;

import org.hibernate.annotations.ColumnDefault;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "tb_users")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@ToString
public class User {

    @Id // 단일 PK로 변경
    @Column(length = 30)
    private String id; 

    @Column(nullable = false, unique = true, columnDefinition = "uuid")
    private UUID uuid;

    @Column(nullable = false, unique = true, length = 255)
    private String email;

    @Column(nullable = false, length = 255)
    private String password;

    @Column(name = "is_active")
    @ColumnDefault("0")
    private Integer isActive;
    
    @Column(name = "is_include_holiday", length = 1)
    private String isIncludeHoliday;

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

    public User (JoinRequest joinRequest)
    {
        this.email = joinRequest.getEmail();
    }
    
}