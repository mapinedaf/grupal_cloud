FROM eclipse-temurin:21-jdk-alpine AS deps
WORKDIR /app
COPY target/*.jar app.jar
RUN java -Djarmode=layertools -jar app.jar extract

FROM eclipse-temurin:21-jre-alpine
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring
WORKDIR /app

COPY --from=deps /app/dependencies/ ./
COPY --from=deps /app/spring-boot-loader/ ./
COPY --from=deps /app/snapshot-dependencies/ ./
COPY --from=deps /app/application/ ./

EXPOSE 6767
ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]