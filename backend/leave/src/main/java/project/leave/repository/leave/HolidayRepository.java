package project.leave.repository.leave;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import project.leave.entity.leave.Holiday;

@Repository
public interface HolidayRepository extends JpaRepository<Holiday, String> {
    
    // 이미 저장된 날짜인지 확인하여 중복 저장 방지
    boolean existsByDate(String date);
}