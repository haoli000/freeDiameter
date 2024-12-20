# Stage 1: Build freeDiameter
FROM ubuntu:22.04 AS builder

# Set non-interactive mode for apt-get to avoid prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    meson cmake make gcc g++ bison flex libsctp-dev \
    libgnutls28-dev libgcrypt-dev libidn11-dev libpq-dev \
    libmysqlclient-dev cmake-curses-gui \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy all files from the current directory to the container
COPY . /usr/src/freeDiameter

# Set the working directory
WORKDIR /usr/src

# Build test_app
RUN mkdir /usr/src/freeDiameter/build && cd /usr/src/freeDiameter/build && \
    meson .. && \
    meson compile && \
    meson install 

# Build freeDimaterd
RUN mkdir /usr/src/freeDiameter/fDbuild && cd /usr/src/freeDiameter/fDbuild && \
    cmake .. && \
    make && \
    make install

# Stage 2: Create the final lightweight image
FROM ubuntu:22.04

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    openssl libsctp-dev lksctp-tools libgnutls30 libgcrypt20 libidn11-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Setup configuration files
RUN mkdir -p /etc/freeDiameter
RUN openssl req -new -batch -x509 -days 3650 -nodes     \
    -newkey rsa:1024 -out /etc/freeDiameter/cert.pem -keyout /etc/freeDiameter/privkey.pem \
    -subj /CN=dra1.localdomain
RUN openssl dhparam -out /etc/freeDiameter/dh.pem 1024
RUN echo 'Identity = "dra1.localdomain";\n\
    Realm = "localdomain";\n\
    # Port = 3868;\n\
    # SecPort = 3869;\n\
    \n\
    TLS_Cred = "/etc/freeDiameter/cert.pem", "/etc/freeDiameter/privkey.pem";\n\
    TLS_CA = "/etc/freeDiameter/cert.pem";\n\
    TLS_DH_File = "/etc/freeDiameter/dh.pem";' > /etc/freeDiameter/diameter.conf


# Copy the installed binaries and libraries from the builder stage
COPY --from=builder /usr/local/bin/freeDiameterd /usr/local/bin/
COPY --from=builder /usr/local/lib/ /usr/local/lib/
COPY --from=builder /usr/lib/x86_64-linux-gnu/ /usr/lib/x86_64-linux-gnu/
COPY --from=builder /usr/local/include/freeDiameter/ /usr/local/include/freeDiameter/

ENV LD_LIBRARY_PATH=/usr/local/lib:/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH

# Expose the Diameter protocol port
EXPOSE 3868

# Set default command
CMD ["/usr/local/bin/freeDiameterd", "-c", "/etc/freeDiameter/diameter.conf"]

