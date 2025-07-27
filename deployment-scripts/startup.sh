#!/bin/bash
APP_JAR="demoapp-0.0.1-SNAPSHOT.jar"
APP_DIR="/opt/demoapp"
LOG_DIR="/var/log/demoapp"
LOG_FILE="$LOG_DIR/application.log"
PID_FILE="$APP_DIR/app.pid"

echo "Running deployment script on remote server..."
mkdir -p "$LOG_DIR"

if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if ps -p "$OLD_PID" > /dev/null
    then
        echo "Application is already running (PID: $OLD_PID). Stopping it..."
        kill "$OLD_PID"
        sleep 10
        if ps -p "$OLD_PID" > /dev/null; then
            echo "Application did not stop gracefully, forcing kill..."
            kill -9 "$OLD_PID"
            sleep 5
        fi
    fi
    rm -f "$PID_FILE"
    echo "Old application stopped."
fi

echo "Starting application..."
nohup java -jar "$APP_DIR/$APP_JAR" > "$LOG_FILE" 2>&1 &
echo $! > "$PID_FILE"
NEW_PID=$(cat "$PID_FILE")
echo "Application started with PID: $NEW_PID"
