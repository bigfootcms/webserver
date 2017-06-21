# webserver
Built on Docker's php:7.1.6-apache image, tailored to support Swarm health checking. Includes Extra features.

    git clone https://github.com/bigfootcms/webserver.git
    cd webserver
    docker build -t bigfootcms/webserver:v0.0.1 --label webserver .
    docker run -d -p 80:80 --network website --name website --add-host='healthcheck:127.0.0.1' bigfootcms/webserver

You will need to specify your volume wih the -v $PWD:/var/www/html option to server your local files.
