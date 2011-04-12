#!/usr/bin/env bash  

DEPLOY_HOST=my-machine-name
JETTY_HOME=/opt/jetty
SCALA_VER=2.8.1
APP_VER=1.0
APP_NAME=myapp
DEPLOY_UPLOAD=$JETTY_HOME/source-webapps
RUBYGEMS_BIN=/var/lib/gems/1.8/bin

upload() {
    ssh $DEPLOY_HOST "rm $DEPLOY_UPLOAD/*"
    
    #change this to your
    scp web/target/scala_$SCALA_VER/$APP_NAME_$SCALA_VER-$APP_VER.war $DEPLOY_HOST:$DEPLOY_UPLOAD/root.war
}

build() {
    sbt clean
    sbt package
}

deploy-server() {
    ssh $DEPLOY_HOST "cd $JETTY_HOME && sudo ./deploy.sh"
}

build
upload
deploy-server
