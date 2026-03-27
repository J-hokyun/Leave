package project.leave.repository.user;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import project.leave.entity.user.UserLeaveTot;

@Repository
public interface UserLeaveTotRepository extends JpaRepository<UserLeaveTot, String>  {
    @Query(value = """
        SELECT 
            'tot' || TO_CHAR(NOW(), 'YYYYMMDD') || 
            LPAD(
                (COALESCE(
                    MAX(SUBSTR(id, 13)::INTEGER), 
                    0
                ) + 1)::TEXT, 
                5, 
                '0'
            )
        FROM tb_user_leave_tot
        WHERE id LIKE 'tot' || TO_CHAR(NOW(), 'YYYYMMDD') || '%'
        """, nativeQuery = true)
    String findNewTotId();

    @Query(value = """
            SELECT *
            FROM tb_user_leave_tot
            WHERE user_id = :userId
            """, nativeQuery = true)
    UserLeaveTot findByUserIdAndYear(@Param("userId") String userId, @Param("year") String year);

    @Query(value = """
            SELECT total_leave_count
            FROM tb_user_leave_tot
            WHERE user_id = :userId AND year = :year
            """, nativeQuery = true)
    int findLeaveCountByUserIdAndYear(@Param("userId") String userId, @Param("year") String year);

}
