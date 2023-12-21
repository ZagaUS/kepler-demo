#!/bin/bash

# Define the target URL and port
TARGET_URL_PROTOCOL=http
TARGET_URL="otel-kepler-backend.apps.zagaopenshift.zagaopensource.com"
TARGET_PORT=9111
OTEL_CONFIG_FILE=./edge/edge-otel-collector/1-kepler-microshift-otelconfig.yaml
HOSTNAME=$(hostname)


echo "Microshift opentelemetry config file  : $OTEL_CONFIG_FILE"
echo "Current system hostname is            : $HOSTNAME"
echo "provided external OTEL collector URL  : http://$TARGET_URL:$TARGET_PORT"

echo ""

# Function to check accessibility using telnet
check_telnet_accessibility() {
    if command -v telnet &> /dev/null; then
        if timeout 4 telnet "$TARGET_URL" "$TARGET_PORT" | grep -q "Connected to"; then
            return 0
        else
            return 1
        fi
    else
        echo "Telnet is not installed. Please install telnet to check accessibility."
        return 1
        exit 1
    fi
}

# Function to check accessibility using ping
check_ping_accessibility() {
    if command -v ping &> /dev/null; then
        if ping -c 4 "$TARGET_URL" &> /dev/null; then
            return 0
        else
            return 1
        fi
    else
        echo "Ping is not installed. Please install ping to check accessibility."
        return 1
        exit 1
    fi
}

### Connection status check for given External OpenTelemetry Collector

connectivity_check(){
    if check_telnet_accessibility && check_ping_accessibility; then
    echo "Status       :Both telnet and ping are successful."
    return 0
else
    echo "Status       : Host not accessible"
    return 1
    exit 1
fi
}

update_external_otel_url(){
    if sed -i 's/EXTERNAL_OTEL_HOSTNAME/'"${TARGET_URL}"'/g' ${OTEL_CONFIG_FILE} && sed -i 's/EXTERNAL_OTEL_PORT/'"${TARGET_PORT}"'/g' ${OTEL_CONFIG_FILE} && sed -i 's/EXTERNAL_OTEL_PROTOCOL/'"${TARGET_URL_PROTOCOL}"'/g' ${OTEL_CONFIG_FILE} ; then
        return 0
    else
        # echo "Hostname replacement failed. Exiting the script."
        return 1
        exit 1
    fi
}

change_exported_instance_name() {

    # Check if the hostname is localhost
    if [ "$HOSTNAME" = "localhost" ]; then
        # echo "Hostname is localhost. Exiting the script."
        return 0
    fi

    # Perform the hostname replacement
    if sed -i 's/HOSTNAME/'"${HOSTNAME}"'/g' ${OTEL_CONFIG_FILE}; then
        echo "Hostname replacement completed."
    else
        # echo "Hostname replacement failed. Exiting the script."
        return 1
        exit 1
    fi
}


if connectivity_check; then
  update_external_otel_url
  echo ""
  change_exported_instance_name
else
    echo "Connectivity check failed. Exiting..."
    exit 1
fi
