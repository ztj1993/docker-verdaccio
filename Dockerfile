FROM ztj1993/webproc:0.4.0 as webproc
FROM verdaccio/verdaccio:4.8.1 as verdaccio


FROM node:14.15.0-alpine

LABEL maintainer="Ztj <ztj1993@gmail.com>"

RUN apk --no-cache add dumb-init

COPY --from=webproc /bin/webproc /bin/webproc
COPY --from=verdaccio /opt/verdaccio /verdaccio
COPY --from=verdaccio /verdaccio/conf/config.yaml /verdaccio/config.yaml

ADD entrypoint /verdaccio/bin/entrypoint
ADD webproc.toml /data/webproc.toml

RUN mkdir -p /data \
  && mkdir -p /data/conf \
  && mkdir -p /data/storage \
  && ln -s /verdaccio/bin/entrypoint /bin/entrypoint \
  && ln -s /verdaccio/bin/verdaccio /bin/verdaccio \
  && chown -R node:root /data \
  && chown -R node:root /verdaccio \
  && chown node:root /verdaccio \
  && chmod +x /verdaccio/bin/entrypoint \
  && sed -i "s@/verdaccio/storage/data@/data/storage@" /verdaccio/config.yaml \
  && sed -i "s@/verdaccio/plugins@/data/plugins@" /verdaccio/config.yaml \
  && sed -i "s@/verdaccio/storage/htpasswd@/data/conf/htpasswd@" /verdaccio/config.yaml

WORKDIR /data
VOLUME /data/conf
VOLUME /data/storage

USER node

EXPOSE 4873 8080

ENTRYPOINT ["entrypoint"]

CMD webproc /data/webproc.toml
