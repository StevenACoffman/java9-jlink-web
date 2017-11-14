# A JDK 9 with Alpine Linux
FROM alpine:3.6 as builder
# Add the musl-based JDK 9 distribution
RUN mkdir /opt
# Download from http://jdk.java.net/9/

ARG OPENJDK9_ALPINE_URL=http://download.java.net/java/jdk9-alpine/archive/181/binaries/jdk-9-ea+181_linux-x64-musl_bin.tar.gz
# Download and untar openjdk9-alpine from $OPENJDK9_ALPINE_URL
RUN mkdir -p /usr/lib/jvm \
  && wget -c -O- --header "Cookie: oraclelicense=accept-securebackup-cookie" $OPENJDK9_ALPINE_URL \
    | tar -zxC /usr/lib/jvm

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

# Set up env variables
ENV JAVA_HOME /usr/lib/jvm/jdk-9
ENV PATH=$PATH:$JAVA_HOME/bin

WORKDIR /app
RUN mkdir -p /app/src
COPY ./src /app/src

RUN mkdir -p build/classes/main
RUN javac -d build/classes/main \
    src/main/java/module-info.java \
    src/main/java/com/example/http/Main.java

RUN mkdir -p build/jmods
RUN jar --create --file build/jmods/http-server-1.0-SNAPSHOT.jar \
    --main-class com.example.http.Main \
    -C build/classes/main .
ENV TARGET_JMODS=$JAVA_HOME/jmods
RUN ls -la $JAVA_HOME/bin
RUN jlink --module-path build/jmods:$TARGET_JMODS \
          --strip-debug --vm server --compress 2 \
          --class-for-name --no-header-files --no-man-pages \
          --dedup-legal-notices=error-if-not-same-content \
          --add-modules http.server \
          --output build/jre/native
RUN du -csh build/jre/native
FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /app/build/jre/native/bin

COPY --from=builder /app/build/jre/native /app/build/jre/native

CMD ["/app/build/jre/native/bin/java", "-m", "http.server"]
