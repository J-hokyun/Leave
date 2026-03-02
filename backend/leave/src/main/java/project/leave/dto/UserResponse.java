package project.leave.dto;


import lombok.Getter;
import lombok.Setter;
import project.leave.entity.user.User;

@Getter
@Setter
public class UserResponse {
    private String id;
    private String email;

    public UserResponse(User user){
        this.id = user.getId();
        this.email = user.getEmail();
    }

}
