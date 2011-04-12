### z-deploy

*z-deploy* is an attempt to automate the deployment process for a Scala/Java web application to a Jetty app server with ***zero*** downtime. The default Jetty deployment will first undeploy the existing application, then deploy the new one. This leaves us with a time window of a couple of seconds when the application is unavailable. That is extremely undesirable when building an API service that has to stay up at all time.

In addition it is quite easy for apps that rely on Jetty's "hot" redeploys to get bitten by classloader leaks and run out of PermGen space. z-deploy avoids that by always starting a new JVM and stopping the old one.

### How it works

Jetty alone is not enough to solve this problem. We need to hide it behind nginx (a reverse HTTP proxy). This way we can replace the Jetty instance with a new one. Here are the details:

* nginx listens on port 80 for HTTP (maybe 443 for HTTPS too) and proxies HTTP requests to Jetty.
* Jetty listens to either internal port 9090 or 9091. It alternates between the two when swapping instances.
* When deploying we modify the Jetty config to use the currently available internal port and start a new Jetty instance.
* We then deploy the application to the new instance:
    * We make sure we change the location of the *webapps* and *run* folders by changing two symlinks so that the Jetty config is valid at all time and we can restart the server at all time using a simple (Ubuntu) *service jetty restart* command.
    * We wait for the app to boot. We do that by periodically requesting a page from the app until we get an OK response.
* We change the nginx configuration, so that it starts proxying requests to the new Jetty instance.
* We stop the old Jetty instance.

### Getting all that to work for your application

***_z-deploy_ is not an integrated solution (yet)!*** You'd have to clone it and modify some of the files or just use the scripts as an example when building your deployment procedure. Here's a list of files with some explanations on what needs editing:

* deploy.sh - This is the entry point. It uses sbt to rebuild the web application, scp its war file(s) to the target machine and launch the jetty instance swap procedure. The file head contains some bash variables that you need to change such as JETTY_HOME, DEPLOY_HOST, APP_NAME, APP_VER, etc. It uploads the war file (or files) to the $DEPLOY_UPLOAD directory on the target server where it gets picked up by the rest of the scripts. Keep the file in your project's source root. Note that it uses *sudo* to run $JETTY_ROOT/deploy.sh as root, so you'd need to configure sudo to make it allow execution as root without prompting for a password. Make sure you use ssh keys instead of passwords and guard your ssh key well.
* servers/jetty - copy those files once to your Jetty root (/opt/jetty on my server).
* servers/jetty/bin/config.sh - Instead of modifying jetty/bin/jetty.sh and having a maintenance nightmare with jetty upgrades, we keep all our app-specific config here. I use it to store JVM start parameters and other Jetty options. The deployment procedure modifies this file when switching between the 9090/9091 ports.
* servers/jetty/bin/jetty.sh - This is the stock jetty.sh file with a single change - we dot source the config.sh: ***. $JETTY_HOME/bin/config.sh***
* servers/jetty/bin/stop.sh - We need this to stop the old Jetty instance by passing the old pid file as a command line parameter. Note that we use start-stop-daemon to do the job. If you run on something other than Ubuntu, you may need to do a bit more to stop your old instance.
* servers/jetty/Rakefile - This is the script that swaps Jetty instances. You shouldn't be tweaking much in there apart from setting JETTY_HOME and making sure it can run to $JETTY_HOME/run and $JETTY_HOME/deploy. The script creates a subfolder for pid files and war file(s) respectively and keeps around files for the last five deployments. If anything goes bad, you should be able to manually copy files around and bring back an older version of your app.
* servers/nginx/sites-available/app.example.com - one or more nginx site configurations. Note that each of those gets edited by the Rakefile script to reflect the internal port change.

### What's next

Ideally you shouldn't have to clone and edit files in this project. The next step for me would be to make the project use a config file outside the z-deploy source root, say somewhere in your deployee's source code. I'm toying with the idea of including the z-deploy as a git submodule in your project too.
