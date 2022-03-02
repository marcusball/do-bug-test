# do-bug-test



```
docker build -t marcusball/heroku-buildpack-debug:latest .
docker push marcusball/heroku-buildpack-debug:latest
pack build digitalocean-nginx-bug-debug -B marcusball/heroku-buildpack-debug:latest -b heroku/php --run-image digitaloceanapps/apps-run
```

```
docker build -t marcusball/digitalocean-appsrun-debug:0.0.3 docker/digitalocean-appsrun-debug/
docker push marcusball/digitalocean-appsrun-debug:0.0.3
pack build marcusball/digitalocean-nginx-bug-debug:0.0.4 -B marcusball/heroku-buildpack-debug:0.0.1 -b heroku/php --run-image marcusball/digitalocean-appsrun-debug:0.0.3
docker push marcusball/digitalocean-nginx-bug-debug:0.0.4
```