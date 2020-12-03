[GNU Pies](http://www.gnu.org.ua/software/pies/)
[Docker Pulls](https://hub.docker.com/r/graygnuorg/pies)
# GNU Pies docker image

This is the source repository for [GNU Pies](https://hub.docker.com/r/graygnuorg/pies) docker image.

GNU pies is a program invocation and execution supervisor -- a program
that runs a number of external processes and controls their execution.
This image runs `pies` as entrypoint process and is intended to be used as
a base for creating images that need to run several interdependent
processes.

## Image structure

The main configuration file `/etc/pies.conf` looks for files with
suffix `.conf` in the directory `/etc/pies.d` and includes them.
The derived images are supposed to put their configuration files
there.  The recommended approach is to keep a single `component`
statement per configuration file.

### Environment variables

The following environment variables control the logging output:

* `PIES_SYSLOG_SERVER`

The IP address (or `IP:PORT`) of the syslog server.  If `PORT` is not
supplied, 514 is used by default.  Pies communicates with syslog using
UDP.

* `PIES_SYSLOG_FACILITY`

Name of the syslog facility to use for messages.  Default is `daemon`.

* `PIES_SYSLOG_TAG`

Syslog tag to use for messages from the `pies` master process.  Default is
`pies`.

### Preprocessor macros

The following preprocessor macros are available for use in 
configuration files:

* `CF_WITH_ENVAR(VAR,TEXT)`

Temporarily redefine `VAR` to the value of the environment variable `VAR` and
expand `TEXT`.

* `CF_IF_ENVAR(VAR,IF-SET,IF-UNSET)`

If the environment variable `VAR` is defined and has a non-empty value,
expand `IF-SET`, otherwise expand `IF-UNSET`.  Expand `VAR` in `IF-SET`
to the actual value of the environment variable.

* `CF_STDO`

Use this macro in `component` statements to capture standard output and
error and redirect them to the container log or syslog:

```
component X {
    command Y;
    CF_STDO;
}
```

If the `PIES_SYSLOG_SERVER` environment variable is set, standard streams
are redirected to syslog.  Otherwise, they are redirected to the container
stdout/stderr.

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
FROM graygnuorg/pies:1.5
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends apache2
COPY apache2.conf /etc/pies.d
EXPOSE 80 8443
```

### `apache2.conf`

```
component apache2 {
	command "/usr/sbin/apache2ctl -DFOREGROUND";
	CF_STDO;
}
```

## License

GNU Pies is distributed under [GNU General Public License](https://www.gnu.org/licenses/gpl-3.0.html), version 3 or later.  This license applies also to
this image.


