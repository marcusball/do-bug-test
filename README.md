# Nginx epoll bug

This repository contains a basic setup for reproducing a bug within Nginx which would 
cause responses to hang when the responses exceeded roughly 4000 characters while
being read from an upstream source like PHP-FPM. 

This issue occurs on systems which support `epoll`, but which do not support 
the `EPOLLRDHUP` event, such as DigitalOcean's App Platform (and I suspect possibly other
systems running under gVisor, but I cannot test that). 

## Demo

To reproduce this, you can launch an App on DigitalOcean using 
[these Docker Hub images](https://hub.docker.com/r/marcusball/nginx-rdhup-bug/tags):

Note: All this demo does is return a response of the letter "A" repeated ~7000 times. 

### Demo with it not working

`marcusball/nginx-rdhup-bug:without-fix`

Deploy the image with this tag, then attempt to request the page, either by visiting
the App's public URL, or by opening the "Console" within the admin dashboard and
simply running `curl localhost:8080`. This may take between one and five requests,
but after that subsequent requests will hang indefinitely. 

### With the fix

`marcusball/nginx-rdhup-bug:with-fix`

Deploy the image with this tag and all requests should work fine. 

## Building the image yourself

You can build the image yourself with the fix by running `docker build your-image-name .`
without making any modifications to the repository. 

To build the image _without the fix_, open the `Dockerfile` and comment out the 
`RUN sed ...` command on lines 91 and 92. 

## Bug in the wild 

If you don't want to use this image to demo bug, any basic PHP app (configured to use Nginx)
that is deployed using DigitalOcean's App Platform deployment service should experience it. 