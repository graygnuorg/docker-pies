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

`Pies` images are tagged using the following scheme:

```
M.m-D
```

where __M__ and __m__ are major and minor versions _of the image_, and `D` is
the name of the distribution it is based on (`debian` or `alpine`).

This tagging scheme is in use starting with version 2.18.  Until then,
the scheme was

```
D-M.m
```

You can see the versions (or commits) of the software used in a `pies` image
by issuing the following command:

```Shell
docker image inspect -f '{{ index .ContainerConfig.Labels `org.opencontainers.image.description` }}' graygnuorg/pies:TAG
```

(replace __TAG__ with the actual tag of the image you are using.)

Here's an example output:

```
Debian 11-slim, pies 1.8.90, xenv 4.1, syslogrelay cc6f1fcae24204d23dac1a85718de571033608ae
```

For each component, its version is shown, unless it was built from a
particular git commit (as it was in case of `syslogrelay` in the above
example).  For the reference, here are addresses of the corresponding git
repositories:

* https://git.gnu.org.ua/cgit/pies.git
* https://git.gnu.org.ua/cgit/xenv.git
* https://git.gnu.org.ua/cgit/pies.git

### Preprocessor

The default preprocessor is [xenv](https://www.gnu.org.ua/software/xenv/).
It was designed to facilitate the use of environment variables in
configuration files.  Variables can be referred to using the familiar
shell syntax: `$VAR`.  Special forms are provided that allow you to
test for a variable that is unset or null and provide expansions depending
on that.  See the [Xenv manual](https://www.gnu.org.ua/software/xenv/)
for a detailed discussion.

The preprocessor binary is installed in `/pies/bin`.

### Additional software

In addition to the above, [syslogrelay](https://puszcza.gnu.org.ua/projects/syslogrelay/)
is installed in `/pies/bin`.  Use it to relay syslog messages to a log hub.

Notice, that in order to keep the iamge simple, `syslogrelay` is compiled
without support for TLS.

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
COPY apache2.conf syslogrelay.conf /pies/conf.d/
EXPOSE 80 443
```

### `apache2.conf`

This configuration file starts apache and makes sure its diagnostics
is properly captured, i.e. either sent to the container's stdout/stderr,
or, if the environment variable `PIES_SYSLOG_SERVER` is set, to the syslog.
In the latter case, care is taken to ensure that `apache` is started after
`syslogrelay` is already up and running.

See the [description](https://www.gnu.org.ua/software/xenv/manual/Directives.html) of the `$$ifset` directive and the discussion of
[variable references](https://www.gnu.org.ua/software/xenv/manual/Variable-references.html), for details.

```
component apache2 {
	mode respawn;
	command "/usr/sbin/apache2ctl -DFOREGROUND";
$$ifset PIES_SYSLOG_SERVER
	prerequisites (syslogrelay);
$$endif
	stderr ${PIES_SYSLOG_SERVER:|syslog daemon.err|file /proc/1/fd/2};
        stdout ${PIES_SYSLOG_SERVER:|syslog daemon.info|file /proc/1/fd/1};
}
```

### `syslogrelay.conf`

This configuration file starts up `syslogrelay`, if the variable `PIES_SYSLOG_SERVER` is set.

```
$$ifset PIES_SYSLOG_SERVER
component syslogrelay {
        mode respawn;
        command "/pies/bin/syslogrelay ${PIES_SYSLOG_SERVER}";
	stderr file /proc/1/fd/2;
        stdout file /proc/1/fd/1;
}
$$endif
```

## Multi-stage builds

This image is suitable for use in multi-stage builds.  Make sure both
images are based on the same distribution and copy the directory `/pies`
from the `pies` image to the destination.  Then, expose port 8073 and
declare `/pies/conf/rc` as entrypoint.  It is also suggested to set
the environment variable `PATH` as shown in the example below.

The following example Dockerfile builds an image for Varnish Cache with
GNU pies as supervisor:

```Dockerfile
FROM graygnuorg/pies:latest as pies
FROM varnish:stable
COPY --from=pies /pies /pies
COPY varnish.conf /pies/conf.d
ENV PATH="/pies/sbin:/pies/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ENTRYPOINT ["/pies/conf/rc"]
EXPOSE 8073 80 443
```

## License

GNU Pies is distributed under [GNU General Public License](https://www.gnu.org/licenses/gpl-3.0.html), version 3 or later.  This license applies also to
this image.


