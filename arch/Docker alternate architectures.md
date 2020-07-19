In order to build images on the same machine but with alternate archtures, they need to be registered.

First, call this image which will register them:
```sh
docker run --privileged --rm docker/binfmt:a7996909642ee92942dcd6c
```

Make sure that the /etc/docker/config.json has the 'experimental' field set:
```json
{
    ...
     "experimental": “enabled”
}
```


At this point, you can either restart docker to have the default builder usable for all, OR start creating new builders with buildx:
```sh
docker buildx create --name mybuilder  # optionall `--use` to make this builder the new default
docker buildx inspect --builder mybuilder --bootstrap
```

Then, when building, use buildx and declare the platforms to build for `docker buildx build --platform linux/arm/v7,linux/amd64,linux/riscv64 -t arm-build .`
