# Apacheep
It's a simple Docker image for Apache 2.4 and PHP 7.4, running on the latest Ubuntu release. It also includes git and Composer.

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
docker run -d -p 8080:80 --name pile_of_cinnamon_toasts awesometoast/apacheep

# Access running container's shell (using the example name above)
docker exec -it pile_of_cinnamon_toasts bash
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
docker run -d -p 8080:80 --name pile_of_cinnamon_toasts -v $PWD/app:app awesometoast/apacheep
```

For those unfamiliar, $PWD stands for "print working directory". If you're not running this command from the apacheep directory, you'll need to replace $PWD with an absolute path.

### Changing the default modules/extensions installed
You'll find the list of default modules/extensions in the appropriate sections of the Dockerfile. If you know you'll want php-mysqli, for example, you would add this line to the \# PHP section:
```RUN apt-get install -y php-mysqli```


### Adding your own PHP.ini and apache2.conf files
You'll find copies of both inside `/apacheep/configs/` which are very close to the default config files for both PHP and Apache. When Apacheep is built, these files will be copied to their expected locations inside the image.

```/apacheep/configs/apache2.conf -> /etc/apache2.conf
/apacheep/configs/php.ini -> /etc/php/[PHP VERSION, e.g. '7.4']/apache2/php.ini
```

Note that unlike the volume'd `html` folder above, these config files are copied only when the container is built, so they don't remain "synced" afterward.

Copies of the default config files are also in the /configs folder in case you need them for reference.

#### A note for RedHat/CentOS/Windows Apache users
On those platforms, you're used to things being named `httpd`. But in the Ubuntu/Debian world, they're named `apache2` even though it's all the same stuff. Why? Because reasons. Probably. There are probably reasons. The point is, `apache2.conf` is the same thing as the `httpd.conf`, in the slim-but-possible chance you were wondering about that.

#### Default PHP extensions enabled
bz2, curl, fileinfo, gd2, gettext, mbstring, openssl, pdo_mysql

### Additional customization
You can perform all kinds of other adjustments and/or configuration and/or shenanigans by modifying `/configs/init_script.sh` before running `docker build`

### Anyway, enjoy!
