# Apacheep
It's a simple Docker image for Apache 2.4 and PHP 8.1, running on the latest Ubuntu release. Think "LAMP" minus the "M". It includes git and Composer, and can easily add NPM and others, too.

## Introduction
I work with and build a lot of LAMP applications. Many of them use a hosted database, so I don't always need the "M" in the LAMP stack. I created this to quickly spin up new instances of PHP applications for development or production.

## Developing and using the image
```bash
# Clone it
git clone https://github.com/awesometoast/apacheep.git
cd apacheep

# Customize it (optional, see below)

# Build it
docker build -t awesometoast/apacheep:latest .

# Run it
docker run -d -p 8080:80 awesometoast/apacheep:latest

# Test it
curl -I http://localhost:8080
```

### Some usage examples
```bash
# Use ports 80 and 443
docker run -d -p 80:80 -p 443:443 awesometoast/apacheep

# Use a custom container name
docker run -d -p 8080:80 --name apacheep awesometoast/apacheep

# Access running container's shell (using the example name above)
docker exec -it apacheep bash
```

# Customize it
## Adding your own application content

### Option 1: One-time copy
Anything you add to the `app` directory will be copied to the container's `/app` directory on build. If you won't need to make changes to your PHP app after running the container, this is a good option.

### Option 2: Use a volume (a.k.a. bind mount) to keep the app folder "synced"
Using this method, any changes you make to the `apacheep/app` directory's contents will be automagically applied to the `/app` folder inside your running container and vice-versa. To achieve this, add this line to your `run` command:

```
-v $PWD/app:/app
```

Here's a full example with that included:

```
docker run -d -p 8080:80 --name apacheep -v $PWD/app:app awesometoast/apacheep
```

For those unfamiliar, $PWD stands for "print working directory". If you're not running this command from the apacheep directory, you'll need to replace $PWD with an absolute path.

### Changing the default modules/extensions installed
You'll find the list of default modules/extensions in the appropriate sections of the Dockerfile. If you know you'll want php-mysqli, for example, you would add this line to the \# PHP section:
```RUN apt-get install -y php-mysqli```


### Adding your own PHP.ini and apache2.conf files
You'll find copies of both inside `/apacheep/configs/` which are very close to the default config files for both PHP and Apache. When Apacheep is built, these files will be copied to their expected locations inside the image.

```/apacheep/configs/apache2.conf -> /etc/apache2.conf
/apacheep/configs/php.ini -> /etc/php/[PHP VERSION, e.g. '8.1']/apache2/php.ini
```

Note that unlike the volume'd `app` folder above, these config files are copied only when the container is built, so they don't remain "synced" afterward.

Copies of the default config files are also in the /configs folder in case you need them for reference.

#### Default PHP extensions enabled
bcmath, bz2, cgi, curl, fileinfo, mbstring, openssl, pdo, pdo_mysql


# Using Apacheep in your own project
You could clone and modify it, or you could use it as a base image like so:

Create a new directory with a new Dockerfile with this at the top:
```
FROM awesometoast/apacheep:latest
```

Then optionally add ENV items like so:
```
ENV TOPPING_TYPE "cinnamon"
ENV CERTS_DIR "/etc/ssl/certs"
RUN echo ". /etc/environment" >> /etc/apache2/envvars
RUN echo "export TOPPING_TYPE=${TOPPING_TYPE}" >> /etc/environment
RUN echo "export CERTS_DIR=${CERTS_DIR}" >> /etc/environment
```

Add your own site config file like:
```
COPY ./docker/your-example-site.conf /etc/apache2/sites-available/your-example-site.conf
RUN a2ensite your-example-site
```

You can also add or remove packages/files as desired, of course. Just don't forget to restart Apache in your own Dockerfile after making your changes:
```
RUN service apache2 restart
```