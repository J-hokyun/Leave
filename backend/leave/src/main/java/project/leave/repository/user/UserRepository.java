package project.leave.repository.user;

import java.util.List;
import java.util.Map;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import project.leave.entity.user.User;

@Repository
public interface UserRepository extends JpaRepository<User, String> {
    
    @Query(value = "SELECT * FROM tb_users", nativeQuery = true)
    List<User>findAllUser();

    @Query(value = "SELECT * FROM tb_users WHERE is_active = '1' ", nativeQuery = true)
    List<User>findAbleUser();

    @Query(value = "SELECT * FROM tb_users WHERE email = :email", nativeQuery = true)
    User findByEmail(@Param("email") String email);

    @Query(value = "SELECT * FROM tb_users WHERE id = :userId", nativeQuery = true)
    User findByUserId(@Param("userId") String userId);    

    @Query(value = """
        SELECT 
            'user' || TO_CHAR(NOW(), 'YYYYMMDD') || 
            LPAD(
                (COALESCE(
                    MAX(SUBSTR(id, 13)::INTEGER), 
                    0
                ) + 1)::TEXT, 
                5, 
                '0'
            )
        FROM tb_users
        WHERE id LIKE 'user' || TO_CHAR(NOW(), 'YYYYMMDD') || '%'
        """, nativeQuery = true)
    String getNewUserId();

    @Query(value = "SELECT EXISTS (SELECT 1 FROM tb_users WHERE email = :email)", nativeQuery = true)
    boolean existsByEmail(@Param("email") String email);

    @Query(value = """
    SELECT 
        remaining_leave_count
    FROM tb_users
    WHERE id = :userId
    """, nativeQuery = true)
    Double findRemainCountByUserId(@Param("userId") String userId);

    @Query(value = "DELETE FROM tb_users WHERE id = :userId", nativeQuery = true)
    @Modifying
    void deleteByuserId(@Param("userId") String userId);

    
    
}
