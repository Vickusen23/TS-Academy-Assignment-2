FROM alpine:3.19

# Install required packages (bash, iputils for ping, procps for uptime/df)
RUN apk add --no-cache bash iputils procps coreutils

WORKDIR /app

# Copy application scripts into image
COPY app/ .

# Ensure executable permissions inside container
RUN chmod +x /app/diagnostic.sh /app/health-check.sh

# Set ENTRYPOINT to run diagnostic.sh by default
ENTRYPOINT ["/app/diagnostic.sh"]

# Default command if no argument is passed
CMD ["help"]
