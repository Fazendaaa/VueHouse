FROM alpine:3.13 as base
LABEL author="fazenda"
LABEL project="vuehouse"

RUN [ "apk", "add", "--no-cache", \
  "curl=7.76.1-r0", \
  "g++=10.2.1_pre1-r3", \
  "make=4.3-r0", \
  "nodejs=14.16.1-r1", \
  "npm=14.16.1-r1", \
  "python3=3.8.8-r0" \
]

#===============================================================================

FROM alpine:3.13 as install

# DUMB AF, but it's a start
COPY --from=base / /
WORKDIR /usr/src/app

COPY package.json .

RUN [ "npm", "install" ]

#===============================================================================

FROM alpine:3.13 as build

WORKDIR /usr/src/app

COPY --from=install / /
COPY . .

RUN [ "npm", "run", "build" ]

#===============================================================================

FROM alpine:3.13 as dev

RUN [ "apk", "add", "--no-cache", \
  "npm=14.16.1-r1" \
]

WORKDIR /usr/src/app

RUN [ "npm", "install", "--global", "serve" ]

COPY --from=build /usr/src/app/dist /usr/src/app/dist

EXPOSE 8000
