== Smaller Java 9 apps in Docker

This project showcases what is in my opinion the coolest features in JDK 9:

 * ability to create custom runtime for your application
 * native support for Alpine Linux

Those both boil down to more efficient container usage.
Space-wise.

Creating a custom runtime for your app means
that you can drop all the useless modules from your packaging.
Like in this example,
why should a server application ship with all the user interface toolkits
that Java ships with (AWT, Swing, and JavaFX).

Being able to put that custom runtime natively on Alpine Linux gives you
really slim end result.
People are routinely using Alpine Linux for small containers,
and community has maintained a patched JRE for Java people.
That was fine for a long time,
but now we no longer have to use an unofficial JRE.

=== TL; DR version

```
GIT_REVISION=$(git rev-parse HEAD)
REPOSITORY=stevenacoffman/java9-jlink-web
docker build \
        -t "${REPOSITORY}:GITSHA-${GIT_REVISION}" \
        -t "${REPOSITORY}:latest" \
        .
docker run -it -p 9000:9000 stevenacoffman/java9-jlink-web
```

=== Acknowledgments

+ Java web code and jlink flags comes from [vmj http-server](https://github.com/vmj/http-server) [I'm an inline-style link](https://www.google.com).
+ Combining jlink with CDS is from [Matthew Gilliard's blog](http://mjg123.github.io/2017/11/07/Java-modules-and-jlink.html)

=== Run the container image

Running the container is old news:

```
  docker run -p 9000:9000 stevenacoffman/java9-jlink-web
```
