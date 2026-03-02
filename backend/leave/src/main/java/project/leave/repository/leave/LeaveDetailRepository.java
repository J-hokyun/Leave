package project.leave.repository.leave;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import project.leave.entity.leave.LeaveDetail;

public interface LeaveDetailRepository extends JpaRepository<LeaveDetail, String> {

    @Query(value = """
        SELECT 
            'detl' || TO_CHAR(NOW(), 'YYYYMMDD') || 
            LPAD(
                (COALESCE(
                    MAX(SUBSTR(id, 13)::INTEGER), 
                    0
                ) + 1)::TEXT, 
                5, 
                '0'
            )
        FROM tb_leave_detail
        WHERE id LIKE 'detl' || TO_CHAR(NOW(), 'YYYYMMDD') || '%'
        """, nativeQuery = true)
    String getNewId();

    @Query(value = """
        SELECT 
            *
        FROM tb_leave_detail
        WHERE user_id = :userId AND leave_type_code = :code
        """, nativeQuery = true)
    Optional<LeaveDetail> findByUserIdAndCode(@Param("userId") String userId, @Param("code") String code);

    @Query(value = "SELECT * FROM tb_leave_detail WHERE user_id = :userId", nativeQuery=true)
    List<LeaveDetail>getLeaveDetailList(@Param("userId") String userId);

    @Query(value = "DELETE FROM tb_leave_detail WHERE user_id = :userId", nativeQuery = true)
    void deleteByuserId(@Param("userId") String userId);


}
