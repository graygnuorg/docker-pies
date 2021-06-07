[GNU Pies](http://www.gnu.org.ua/software/pies/) |
 [Docker Pulls](https://hub.docker.com/r/graygnuorg/pies) |
 [xenv](https://www.gnu.org.ua/software/xenv/)
# GNU Pies docker image

This is the source repository for [GNU Pies](https://hub.docker.com/r/graygnuorg/pies) docker image.

GNU pies is a program invocation and execution supervisor -- a program
that runs a number of external processes and controls their execution.
This image runs `pies` as entrypoint process and is intended to be used as
a base for creating images that need to run several interdependent
processes.

## Image structure

GNU pies is installed into the `/pies` directory.  The main configuration
file is `/pies/conf/pies.conf`.  It looks for files with suffix `.conf` in
the directory `/pies/conf.d` and includes them.  The derived images are
supposed to put their configuration files there.  The recommended approach
is to keep a single `component` statement per configuration file.

### Preprocessor

The default preprocessor is [xenv](https://www.gnu.org.ua/software/xenv/).
It was designed to facilitate the use of environment variables in
configuration files.  Variables can be referred to using the familiar
shell syntax: `$VAR`.  Special forms are provided that allow you to
test for a variable that is unset or null and provide expansions depending
on that.  See the [online documentation](http://man.gnu.org.ua/manpage/?1+xenv)
for a detailed discussion.

The preprocessor binary is installed in `/pies/bin`.

### Environment variables

The following environment variables control the behavior of `pies`.

* `PIES_PREPROCESSOR`

External command that pies will use to preprocess its configuration files.
The default is `xenv`.  Apart from it, this image contains [GNU m4](https://www.gnu.org/software/m4).  

* `PIES_SYSLOG_SERVER`

The IP address (or `IP:PORT`) of the syslog server.  If `PORT` is not
supplied, 514 is used by default.  Pies communicates with syslog using
UDP.

* `PIES_SYSLOG_FACILITY`

Name of the syslog facility to use for messages.  Default is `daemon`.

* `PIES_SYSLOG_TAG`

Syslog tag to use for messages from the `pies` master process.  Default is
`pies`.

### Control port

`pies` listens for control requests on port 8073.  This port is exposed
by the image, so you can use it to remotly monitor and control the state of
processes run in the container.  For example, supposing the port was properly
mapped when creating the container, the following command will display
the list of configured and running components:

```Shell
piesctl --url inet://127.0.0.1:8073 list
```

See [piesctl](http://www.gnu.org.ua/software/pies/manual/piesctl.html)
for a detailed description of the `piesctl` interface.

## Example

The following, a bit contrived, example creates an image for running
`apache2` using `pies` as a supervisor:

### `Dockerfile`

```Dockerfile
FROM graygnuorg/pies:latest
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends apache2
COPY apache2.conf /pies/conf.d
EXPOSE 80 8443
```

### `apache2.conf`

```
component apache2 {
	command "/usr/sbin/apache2ctl -DFOREGROUND";
$$ifdef PIES_SYSLOG_SERVER
        stdout syslog info;
        stderr syslog err;
$$else
        stdout file /proc/1/fd/1;
        stderr file /proc/1/fd/1;
$$endif
}
```

## Multi-stage builds

This image is suitable for use in multi-stage builds.  The following
example Dockerfile builds an image for Varnish Cache with GNU pies
as supervisor:

```Dockerfile
FROM graygnuorg/pies:latest as pies
FROM varnish:stable
COPY --from=pies /pies /pies
COPY varnish.conf /pies/conf.d
ENTRYPOINT ["/pies/conf/rc"]
EXPOSE 8073 80 8443
```

## License

GNU Pies is distributed under [GNU General Public License](https://www.gnu.org/licenses/gpl-3.0.html), version 3 or later.  This license applies also to
this image.


