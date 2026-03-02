package project.leave.dto.leave;
import java.util.UUID;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@ToString
public class UsedHistoryResponse {
    // private String id;
    private UUID uuid;
    private String date;
    private String reason;
    private String hasNext;
    private String hasPrev;

}