# Building a Chocolatey Server VM

This document covers how to build a Chocolatey Server Virtual Machine.  This Vm can be used for hosting your own Chocolatey package feed.

This document will cover creating a Virtual Machine using [Hyper-V](https://learn.microsoft.com/en-us/virtualization/hyper-v-on-windows/quick-start/enable-hyper-v) as the hypervisor.  If you are using a different hypervisor (such as Virtual Box), these step, you will need to adjust the steps to create the Virtual machine.

This VM will use the following components:

| **Component**                                    | **Purpose**                               | **Description**                                        |
|--------------------------------------------------|-------------------------------------------|--------------------------------------------------------|
| [Alpine Linux](https://www.alpinelinux.org/)     | VM Operating System                       | Alpine Linux is a lightweight Linux operating system.  Since this VM will only be serving packages, the small footprint of Alpine Linux is ideal  |
| [BaGetter](https://github.com/bagetter/BaGetter) | NuGet Server                              | BaGetter is an open-source (MIT license) implementation of a NuGet server that can server Chocolatey packages.  Bagetter is written in .NET 8 (.NET Core) and can therefore run on Linux |
| [.NET 8](https://dotnet.microsoft.com/en-us/download/dotnet/8.0) | .NET runtime              | BaGetter is written in .NET, so the .NET 8 runtime is required |
| [NGINX](https://nginx.org/en/)                   | Web Server/Reverse Proxy for Nuget Server | BaGetter runs through the Kestrel server built into .NET, but it is typical to put a full web server like IIS or NGINX in front of Kestrel |


## 1 - Download the latest version of Alpine Linux

Navigate to the [Alpine Linux download page](https://www.alpinelinux.org/downloads/).  The *Virtual* option is what to download.

You need to have Alpine Linux 3.20 or later as the .NET 8 SDK package is only available on Alpine 3.20 or later.

Save the ISO file to your machine as it will be used to install Alpine Linux on the VM.

## 2 - Create a Virtual Machine in your Hypervisor

## 3 - Install Alpine Linux on the VM

## 4 - Adjust the /tmp size on the VM

When a package is uploaded to BaGetter, BaGetter will write a temporary file of the package into the `/tmp` directory.  As such, the `/tmp` directory needs to be large enough to handle any packages you upload.  If you create packages for applications such as Microsoft Office or Adobe Acrobat Reader and embed the installers in the package, the resulting chocolatey packages can be quite large, sometimes between 1-2 GB in size.  As such, you need to adjust the `/tmp` space on the VM to be able to handle such packages.



## 5 - Configure a static IP address for the virtual machine

By default, the VM will have DHCP enabled.  However, typically you want a server to to always be on a well known IP address so clients know where to find it.

To configure a static IP address in Alpine Linux, edit the `/etc/network/interfaces` file.

By default, you will see configuration that looks like the following

```text
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
```

It is the last line (`iface eth0 inet dhcp`) that s configuring the VM to use DHCP.  Comment this line out by placing a pound sign (`#`) at the beginning of this line.

Then, add the following lines to the end of the file to configure a static IP address. Substitute in teh appropriate IP address and gateway address.  Also note that the subnet mask is specificed using CIDR notation in the address field.

```text
iface eth0 inet static
    address 192.168.68.50/24
    gateway 192.168.68.1
    hostname choco-server

```

For the new IP address to take effect, you need to either restart networking or reboot the computer.  To restart networking with rebooting, use teh following command.

```bash
service networking restart
```

## 5 - Configure Alpine Linux to Allow Acess to the Alpine Community Repository

By default, the [Alpine Commyunity repository]((https://wiki.alpinelinux.org/wiki/Repositories)) is commented out in the `/etc/apk/repositories`.  We need to allow access to the Alpine community repo to install the required packages for our Chocolatey server.

To do this, edit the `/etc/apk/repositories` file and uncomment the line that references the community repo.

```text
#/media/cdrom/apks
http://dl-cdn.alpinelinux.org/alpine/v3.2/main
http://dl-cdn.alpinelinux.org/alpine/v3.2/community
```

When done, update your package indexes by running `apk update`

```bash
apk update
```

## 6 - Add supporting packages to Alpine Linux

Now that you have access to the community repo, add in the following packages.

We will need [curl](https://curl.se/docs/manpage.html) to download BaGetter in a future step, so install curl.

```bash
apk add curl
```

Also, it can be useful to install the [nano](https://www.nano-editor.org/) text editor as an alternative to vi

```bash
apk add nano
```

## 7 - Create config User

You cannot ssh into this machine as root, but at some point you will need to in order to manage the machine.  For this, you will create another user named `admin` and another group named `config` that you will use to manage the machine.

First, create the config group

```bash
addgroup -S config
```

Then add the user

```bash
adduser -h /home/admin -s /bin/ash -G config admin
```

## 8 - Configure doas Package

`doas` is the Alpine linux equivalent of `sudo`.

First, install the `doas` package

```bash
apk add doas
```

Next, create the `doas.conf` file.  The `wheel` group will be the group that has *doas* permissions.

```bash
echo 'permit :wheel' > /etc/doas.d/doas.conf
```

Next, add the `wheel` group

```bash
addgroup wheel
```

Finally, add the `admin` user to the `wheel` group.

```bash
addgroup config wheel
```

To run a command using `doas`, the syntax is

```bash
doas <command> <arguments>
```

## 9 - Create a bagetter user

This user will be used to run the bagetter server.

- the `-D` option is used to specify a disabled password, so this user cannot login (but can run the BaGetter service)

```bash
adduser -D -g 'BaGetter User' bagetter -G users
```

## 10 - Install .NET 8 SDK

BaGetter is written using .NET 8, so the [.NET 8 SDK](https://pkgs.alpinelinux.org/packages?name=dotnet8-sdk&branch=edge&repo=&arch=x86_64&origin=&flagged=&maintainer=) needs to be installed for BaGetter to run.

Install the .NET 8 SDK using `apk`

```bash
apk add dotnet8-sdk
```

When finished, you can verify .NET is installed using the following command.

```bash
dotnet --version
```

## 11 - Download and install the BaGetter software

[BaGetter](https://www.bagetter.com/) is a lightweight, open-source Nuget server written in .NET Core.  As such, it can run on Linux.

To determine the latest release of BaGetter, look at the [releases page on GitHub](https://github.com/bagetter/BaGetter/releases).

Then, use `curl` to download the latest release onto your VM.  Substitute in the URL for the appropriate version.

> **NOTE:** The `-L` is critical so `curl` will follow redirects

```bash
curl -L -O https://github.com/bagetter/BaGetter/releases/download/v1.4.8/bagetter-1.4.8.zip
```

--Unzip BaGetter


## 12 - Configure BaGetter to start on boot



```text
#!/sbin/openrc-run

name="BaGetter NuGet Service"
description="BaGetter NuGet server to serve Chocolatey Packages"

directory=/bagetter/app
command=/usr/bin/dotnet
command_args="/bagetter/app/BaGetter.dll"
command_user=bagetter
command_background="yes"

pidfile="/run/bagetter/bagetter.pid"

depend() {
    need net
}

start_pre() {
        checkpath --directory --owner bagetter:www --mode 0775 /run/bagetter
}
```



### 11 - Install Nginx

NGINX is a web server that will be used as a reverse proxy for BaGetter.  Since BaGetter only handles requests from the local machine (localhost), we need a reverse proxy like NGINX to sit in front of BaGetter and hand off external requests to BaGetter.

First, install the Nginx package using apk

```bash
apk add nginx
```

Then, create a new user (*www*)and group for the nginx web server

```bash
adduser -D -g 'www' www
```

Change ownership of the `var/lib/nginx` directory where nginx will write its logs so nginx can write to this directory

```bash
chown -R www:www /var/lib/nginx
```

Then, create the directory that will be the web server root directory

```bash
mkdir /data/www
```

Give the nginx user (*www*) ownership of this directory

```bash
chown -R www:www /www
```

Make a backup of the existing `nginx.conf` file before proceeding

```bash
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig
```

Create a new `nginx.conf` file with the contents as follows

```text
user                            www;
worker_processes                auto; # it will be determinate automatically by the number of core

error_log                       /var/log/nginx/error.log warn;
#pid                             /var/run/nginx/nginx.pid; # it permit you to use rc-service nginx reload|restart|stop|s

events {
    worker_connections          1024;
}

http {
    include                     /etc/nginx/mime.types;
    default_type                application/octet-stream;
    sendfile                    on;
    access_log                  /var/log/nginx/access.log;
    keepalive_timeout           3000;
    server {
        listen                  80;
        root                    /www;
        index                   index.html index.htm;
        server_name             localhost;
        client_max_body_size    4096m;
        error_page              500 502 503 504  /50x.html;
        location = /50x.html {
              root              /var/lib/nginx/html;
        }

        location = /choco-install.ps1 {
            root              /www/powershell;
        }

        location / {
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Host $host;
            proxy_pass http://127.0.0.1:8080;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }


    }
}        
```
