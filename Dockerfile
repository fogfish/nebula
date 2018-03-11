FROM fogfish/erlang-alpine-rt:20.2

RUN set -e \
   && apk update \
   && apk add socat

ADD _build/default/rel/nebula /usr/local/nebula

ENTRYPOINT /usr/local/nebula/bin/nebula foreground

