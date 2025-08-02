#!/bin/bash
APP_JAR="demoapp.jar"
APP_DIR="/opt/demoapp"
LOG_DIR="/var/log/demoapp"
LOG_FILE="$LOG_DIR/application.log"
PID_FILE="$APP_DIR/app.pid"
JAVA_OPTS="-Xms128m -Xmx256m -Dserver.address=0.0.0.0"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Deployment script started"
mkdir -p "$APP_DIR"
mkdir -p "$LOG_DIR"
chmod 755 "$LOG_DIR"

touch "$LOG_FILE"
chmod 644 "$LOG_FILE"

if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    
    if ps -p "$OLD_PID" > /dev/null; then
        echo "Stopping existing application (PID: $OLD_PID)..."
        kill "$OLD_PID"
        TIMEOUT=30
        while ps -p "$OLD_PID" > /dev/null && [ $TIMEOUT -gt 0 ]; do
            sleep 1
            ((TIMEOUT--))
        done
        if ps -p "$OLD_PID" > /dev/null; then
            echo "Force killing process (PID: $OLD_PID)..."
            kill -9 "$OLD_PID"
            sleep 2
        fi
    fi
    
    rm -f "$PID_FILE"
    echo "Old application stopped."
fi

echo "Starting new application..."
cd "$APP_DIR" || { echo "Failed to enter $APP_DIR"; exit 1; }


nohup java $JAVA_OPTS -jar "$APP_JAR" > "$LOG_FILE" 2>&1 &
NEW_PID=$!
echo $NEW_PID > "$PID_FILE"

sleep 10
if ps -p "$NEW_PID" > /dev/null; then
    echo "Application started successfully with PID: $NEW_PID"
    echo "Access URL: http://$(curl -s ifconfig.me):8080"
    exit 0
else
    echo "ERROR: Application failed to start!"
    echo "Check logs: $LOG_FILE"
    tail -n 50 "$LOG_FILE"
    rm -f "$PID_FILE"
    exit 1
fi
