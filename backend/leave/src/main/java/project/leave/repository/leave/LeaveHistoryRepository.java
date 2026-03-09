package project.leave.repository.leave;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import project.leave.dto.leave.UsedHistoryResponse;
import project.leave.entity.leave.LeaveHistory;

public interface LeaveHistoryRepository extends JpaRepository<LeaveHistory, String> {

    @Query(value = """
        SELECT 
            'hist' || TO_CHAR(NOW(), 'YYYYMMDD') || 
            LPAD(
                (COALESCE(
                    MAX(SUBSTR(id, 13)::INTEGER), 
                    0
                ) + 1)::TEXT, 
                5, 
                '0'
            )
        FROM tb_leave_history
        WHERE id LIKE 'hist' || TO_CHAR(NOW(), 'YYYYMMDD') || '%'
        """, nativeQuery = true)
    String findByNewId();

    @Query(value = "SELECT id FROM tb_leave_history WHERE uuid = :uuid", nativeQuery = true)
    Optional<String> findIdByUuid(@Param("uuid") UUID uuid);

    @Query(value = "SELECT uuid FROM tb_leave_history WHERE id = :id", nativeQuery = true)
    Optional<UUID>  findUuidById(@Param("id") String id);

    @Query(value = """
        SELECT COUNT(*)
        FROM tb_leave_history
        WHERE user_id = :userId
        """, nativeQuery = true)
    int countByUserId(@Param("userId") String userId);

    @Query(value = "DELETE FROM tb_leave_history WHERE user_id = :userId", nativeQuery = true)
    void deleteByuserId(@Param("userId") String userId);

    @Query(value = """
            SELECT A.uuid
                , A.date
                , A.leave_reason
                , B.has_next
                , B.has_prev
            FROM    (
                        SELECT *
                        FROM tb_leave_history
                        WHERE 1=1
                        AND user_id = :userId
                        ORDER BY 
                            ABS(CAST(date AS INTEGER) - CAST(to_char(current_date, 'YYYYMMDD') AS INTEGER)) ASC, 
                            date DESC,
                            id ASC
                        LIMIT 1
                    ) A 
                INNER JOIN 
                    (
                        SELECT id
                            , CASE WHEN LEAD(id) OVER (ORDER BY date, id) IS NOT NULL THEN 'Y' ELSE 'N' END AS has_next
                            , CASE WHEN LAG(id) OVER (ORDER BY date, id) IS NOT NULL THEN 'Y' ELSE 'N' END AS has_prev        
                        FROM tb_leave_history
                        WHERE user_id = :userId
                    ) B ON A.id = B.id
        """, nativeQuery = true)
    UsedHistoryResponse getCurrentHistory(@Param("userId") String userId);

    @Query(value = """
            SELECT A.uuid
                , A.date
                , A.leave_reason
                , B.has_next
                , B.has_prev
            FROM   (
                        -- 1. 기준점 바로 윗열(과거) 데이터 1건 추출
                        SELECT id, uuid, date, leave_reason
                        FROM tb_leave_history
                        WHERE (date > :date OR (date = :date AND id > :id))
                        AND user_id = :userId
                        ORDER BY date, id 
                        LIMIT 1
                    ) A
                INNER JOIN  (
                                SELECT id
                                    , CASE WHEN LEAD(id) OVER (ORDER BY date, id) IS NOT NULL THEN 'Y' ELSE 'N' END AS has_next
                                    , CASE WHEN LAG(id) OVER (ORDER BY date, id) IS NOT NULL THEN 'Y' ELSE 'N' END AS has_prev        
                                FROM tb_leave_history
                                WHERE user_id = :userId
                            ) B ON A.id = B.id
        """, nativeQuery = true)
    UsedHistoryResponse findFirstByAfterDate(@Param("date") String date, @Param("id") String id, @Param("userId") String userId);

    @Query(value = """
            SELECT A.uuid
                , A.date
                , A.leave_reason
                , B.has_next
                , B.has_prev
            FROM   (
                        -- 기준점 바로 윗열(과거) 데이터 1건 추출
                        SELECT id, uuid, date, leave_reason
                        FROM tb_leave_history
                        WHERE (date < :date OR (date = :date AND id < :id))
                        AND user_id = :userId
                        ORDER BY date DESC, id DESC 
                        LIMIT 1
                    ) A
                INNER JOIN  (
                                SELECT id
                                    , CASE WHEN LEAD(id) OVER (ORDER BY date, id) IS NOT NULL THEN 'Y' ELSE 'N' END AS has_next
                                    , CASE WHEN LAG(id) OVER (ORDER BY date, id) IS NOT NULL THEN 'Y' ELSE 'N' END AS has_prev        
                                FROM tb_leave_history
                                WHERE user_id = :userId
                            ) B ON A.id = B.id
        """, nativeQuery = true)
    UsedHistoryResponse findFirstByBeforeDate(@Param("date") String date, @Param("id") String id, @Param("userId") String userId);
    
    @Query(value = """
            SELECT DISTINCT date
            FROM tb_leave_history
            WHERE 1=1
            AND date LIKE SUBSTR(:date, 1, 6) || '%'
            AND user_id = :userId
            ORDER BY date
            """, nativeQuery = true)
    List<String> findAllByMounth (@Param("date") String date, @Param("userId") String userId);

    @Query(value = """
            SELECT *
            FROM tb_leave_history
            WHERE date = :date AND user_id = :userId
            """, nativeQuery = true)
    List<LeaveHistory> findAllByDateAndUserId(@Param("date") String date, @Param("userId") String userId);


    void deleteByUuid(@Param("uuid") UUID uuid);

    int deleteByParentId(@Param("paren") String parentId);

    @Query(value = """
            SELECT parent_id FROM tb_leave_history WHERE uuid = :uuid
            """, nativeQuery = true)
    String findParentId(@Param("uuid") UUID uuid);
}
