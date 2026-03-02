# 1. 실행 환경 설정 (JDK 21)
FROM eclipse-temurin:21-jre-alpine

# 2. 작업 디렉토리 생성
WORKDIR /app

# 3. 빌드된 jar 파일을 컨테이너로 복사
# (주의: CI 단계에서 이미 빌드가 완료된 상태이므로 복사만 하면 됩니다)
COPY build/libs/*.jar app.jar

# 4. 애플리케이션 실행
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "-Dspring.profiles.active=${SPRING_PROFILE}", "app.jar"]