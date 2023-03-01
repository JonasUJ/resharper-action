FROM golang:1.14 AS builder

WORKDIR /build
COPY . .
RUN CGO_ENABLED=0 go build -ldflags="-s -w"
RUN ls -lh

FROM mcr.microsoft.com/dotnet/sdk:7.0
ENV RESHARPER_CLI_VERSION=2022.3.2

RUN mkdir -p /usr/local/share/dotnet/sdk/NuGetFallbackFolder

WORKDIR /resharper
RUN apt-get update
RUN apt-get install unzip
RUN \
  curl -o resharper.zip -L "https://download.jetbrains.com/resharper/dotUltimate.$RESHARPER_CLI_VERSION/JetBrains.ReSharper.CommandLineTools.$RESHARPER_CLI_VERSION.zip" \
  && unzip resharper.zip \
  && rm resharper.zip \
  && rm -rf macos-x64
RUN chmod +x /resharper/inspectcode.sh

# this is the same as the base image
WORKDIR /

COPY --from=builder /build/resharper-action /usr/bin
CMD resharper-action
