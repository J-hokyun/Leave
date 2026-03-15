package project.leave.repository.leave;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import project.leave.entity.leave.Holiday;

@Repository
public interface HolidayRepository extends JpaRepository<Holiday, String> {
    
    // 해당 날짜가 공유일인지 혹은 배치 수행시 이미 저장되어있는지 확인.
    boolean existsByDate(String date);

    @Query(value = """
            select date from tb_holiday where date like substr(:month,1,6) || '%'
            """, nativeQuery = true)
    //해당 월에 존재하는 공휴일 조회
    List<String>findAllHolidaysByMonth(@Param("month") String month);
}