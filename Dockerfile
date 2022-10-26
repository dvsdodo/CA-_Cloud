FROM alpine:3.13.2 AS builder

# Install all dependencies required for compiling busybox
RUN apk add gcc musl-dev make perl

# Download busybox sources
RUN wget https://busybox.net/downloads/busybox-1.35.0.tar.bz2 \
  && tar xf busybox-1.35.0.tar.bz2 \
  && mv /busybox-1.35.0 /busybox

WORKDIR /busybox

# Copy the busybox build config (limited to httpd)
COPY .config .

#Download and unzip CA1
RUN wget https://github.com/dvsdodo/CA1/archive/main.zip
RUN unzip main.zip

# Compile and install busybox
RUN make && make install

# Create a non-root user to own the files and run our server
RUN adduser -D static

# Switch to the scratch image
FROM scratch

EXPOSE 8080

# Copy over the user
COPY --from=builder /etc/passwd /etc/passwd

# Copy the busybox static binary
COPY --from=builder /busybox/_install/bin/busybox /

# Use our non-root user
USER static
WORKDIR /home/static

# Uploads a blank default httpd.conf
# This is only needed in order to set the `-c` argument in this base file
# and save the developer the need to override the CMD line in case they ever
# want to use a httpd.conf
COPY httpd.conf .

# Copy the static website
COPY ca1 .

# Run busybox httpd
CMD ["/busybox", "httpd", "-f", "-v", "-p", "8080", "-c", "httpd.conf", "./menuTatle.html"]
