FROM debian:trixie-slim

RUN useradd --create-home --user-group --shell /bin/bash a

USER a
WORKDIR /home/a

CMD ["/bin/bash"]
