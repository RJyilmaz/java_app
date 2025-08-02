#!/bin/bash
APP_JAR="demoapp.jar"
APP_DIR="/opt/demoapp"
LOG_DIR="/var/log/demoapp"
LOG_FILE="$LOG_DIR/application.log"
PID_FILE="$APP_DIR/app.pid"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Deployment script started"

# Dizinleri oluştur
mkdir -p "$APP_DIR"
mkdir -p "$LOG_DIR"
chmod 755 "$LOG_DIR"

# Log dosyasını oluştur ve izin ver
touch "$LOG_FILE"
chmod 644 "$LOG_FILE"

# Eski uygulamayı durdur
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    
    if ps -p "$OLD_PID" > /dev/null; then
        echo "Stopping existing application (PID: $OLD_PID)..."
        kill "$OLD_PID"
        
        # 30 saniye graceful shutdown için bekle
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

# Yeni uygulamayı başlat
echo "Starting new application..."
cd "$APP_DIR" || { echo "Failed to enter $APP_DIR"; exit 1; }

# Java opsiyonları (Xmx = Max heap size, Xms = Initial heap size)
JAVA_OPTS="-Xms128m -Xmx256m -Dserver.address=0.0.0.0"

nohup java $JAVA_OPTS -jar "$APP_JAR" > "$LOG_FILE" 2>&1 &
NEW_PID=$!
echo $NEW_PID > "$PID_FILE"

# Başlatma kontrolü
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
