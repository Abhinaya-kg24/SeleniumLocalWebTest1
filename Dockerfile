FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

# Copy the build config first so Maven can cache dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source and compile
COPY src ./src
RUN mvn test-compile -B

FROM eclipse-temurin:17-jre-jammy AS runtime
WORKDIR /app

# Install browser dependencies for headless Selenium
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    curl \
    unzip \
    libglib2.0-0 \
    libnss3 \
    libgconf-2-4 \
    libfontconfig1 \
    chromium \
    && rm -rf /var/lib/apt/lists/*

# Copy only the built app from the build stage
COPY --from=build /app/target /app/target

ENV CHROME_BIN=/usr/bin/chromium

# If this image is meant to run tests inside the container, keep this:
CMD ["mvn", "test"]





