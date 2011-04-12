export JAVA_HOME=/opt/java
export JAVA=/opt/java/bin/java
export PATH=$PATH:$JAVA_HOME/bin

export JETTY_USER=www-data
export JETTY_RUN=/opt/jetty/run/pid
export JETTY_PORT=9090
export JAVA_GC_OPTIONS="-XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -XX:+CMSPermGenSweepingEnabled -XX:MaxPermSize=256m"
export JAVA_PRODUCTION_OPTIONS="-XX:+HeapDumpOnOutOfMemoryError"
export JAVA_PROPERTIES="-Denvironment=production -Drun.mode=production"
export JAVA_OPTIONS="$JAVA_GC_OPTIONS $JAVA_PRODUCTION_OPTIONS $JAVA_PROPERTIES"
