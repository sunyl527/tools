FROM golang:1.8 as build

COPY . /go/src/github.com/suny527/webhooktest

ENV CGO_ENABLED=0

RUN curl https://glide.sh/get | sh
RUN cd /go/src/github.com/suny527/webhooktest && \
 glide install && \
 go build

FROM alpine:3.6

COPY --from=build /go/src/github.com/suny527/webhooktest /

EXPOSE 4000

WORKDIR /

CMD ["/webhooktest"]
