package project.leave.entity.leave;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.*;

@Entity
@Table(name = "tb_holiday")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class Holiday {

    @Id
    @Column(length = 8)
    private String date;

    @Column(name = "date_name", length = 255)
    private String dateName;
}
