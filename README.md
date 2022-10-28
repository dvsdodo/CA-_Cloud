# CA-_Cloud
A very small Docker image (~154KB) to run any static website, based on the BusyBox httpd static file server.


Usage
The image is hosted on Docker Hub:

FROM lipanski/docker-static-website:latest

# Copy your static files
COPY . .
Build the image:

docker build -t my-static-website .
Run the image:

docker run -it --rm -p 8080:8080 my-static-website
Browse to http://localhost:8080.

If you need to configure the server in a different way, you can override the CMD line:

FROM lipanski/docker-static-website:latest

# download CA1 files

RUN wget https://github.com/dvsdodo/CA1/archive/main.tar.gz \
  && tar xf main.tar.gz \
  && rm main.tar.gz \
  && mv /CA1-main /home/static

# Copy your static files
COPY . .

CMD ["/busybox", "httpd", "-f", "-v", "-p", "8080", "-c", "httpd.conf", "./index.html"]

NOTE: Sending a TERM signal to your TTY running the container won't get propagated due to how busybox is built. Instead you can call docker stop (or docker kill if can't wait 15 seconds). Alternatively you can run the container with docker run -it --rm --init which will propagate signals to the process correctly.

FAQ
How can I serve gzipped files?
For every file that should be served gzipped, add a matching [FILENAME].gz to your image.

How can I use httpd as a reverse proxy?
Add a httpd.conf file and use the P directive:

P:/some/old/path:[http://]hostname[:port]/some/new/path


How can I implement allow/deny rules?
Add a httpd.conf file and use the A and D directives:

A:172.20.         # Allow address from 172.20.0.0/16
A:10.0.0.0/25     # Allow any address from 10.0.0.0-10.0.0.127
A:127.0.0.1       # Allow local loopback connections
D:*               # Deny from other IP connections

References
- https://github.com/lipanski/docker-static-website#readme

- https://lipanski.com/posts/smallest-docker-image-static-website

- https://mailchimp.com/en-gb/features/website-builder/?gclid=Cj0KCQjwteOaBhDuARIsADBqRehMQUpMWo0J2SBFfW5JXyG7trUCliGcglKC2g4mv8r2AQOp5hjMSEAaAmhWEALw_wcB&gclsrc=aw.ds

- https://www.youtube.com/watch?v=4pRo6Ud1JI8
