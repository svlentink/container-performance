FROM alpine
ENTRYPOINT ["/entrypoint"]
COPY install_bash.sh /
RUN /install_bash.sh
