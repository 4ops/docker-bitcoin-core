FROM 4ops/alpine-glibc:3.10 AS build

RUN apk --no-cache add gnupg
RUN gpg --batch --recv-keys 90C8019E36C2E964

ARG BITCOIN_VERSION

ENV BITCOIN_VERSION=${BITCOIN_VERSION:-0.19.0.1}
ENV BITCOIN_URL="https://bitcoin.org/bin/bitcoin-core-${BITCOIN_VERSION}"
ENV BITCOIN_PACKAGE="bitcoin-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz"

RUN wget "${BITCOIN_URL}/SHA256SUMS.asc" -O SHA256SUMS.asc
RUN gpg --verify SHA256SUMS.asc
RUN wget "${BITCOIN_URL}/${BITCOIN_PACKAGE}" -O $BITCOIN_PACKAGE
RUN grep " ${BITCOIN_PACKAGE}\$" SHA256SUMS.asc | sha256sum -c -
RUN tar -xvzf $BITCOIN_PACKAGE
RUN mkdir -p /install/bin
RUN mv "bitcoin-${BITCOIN_VERSION}/bin/bitcoind" /install/bin
RUN mv "bitcoin-${BITCOIN_VERSION}/bin/bitcoin-cli" /install/bin
RUN mv "bitcoin-${BITCOIN_VERSION}/bin/bitcoin-tx" /install/bin

COPY docker-entrypoint.sh /install/entrypoint.sh

FROM 4ops/alpine-glibc:3.10 AS release

ENV BITCOIN_DATA=/home/bitcoin/.bitcoin

COPY --from=build /install .

RUN adduser -S bitcoin && apk --no-cache add su-exec

VOLUME ["/home/bitcoin/.bitcoin"]

EXPOSE 8332 8333 18332 18333 18444

ENTRYPOINT ["/entrypoint.sh"]

CMD ["bitcoind"]
