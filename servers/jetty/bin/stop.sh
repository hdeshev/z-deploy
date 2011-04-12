#!/usr/bin/env bash  

JETTY_PID=$1

running()
{
  local PID=$(cat "$1" 2>/dev/null) || return 1
  kill -0 "$PID" 2>/dev/null
}

start-stop-daemon -K -p"$JETTY_PID" -d"$JETTY_HOME" -a "$JAVA" -s HUP
      
TIMEOUT=30
while running "$JETTY_PID"; do
    if (( TIMEOUT-- == 0 )); then
        start-stop-daemon -K -p"$JETTY_PID" -d"$JETTY_HOME" -a "$JAVA" -s KILL
    fi
    
    sleep 1
done
