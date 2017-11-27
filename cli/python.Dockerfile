FROM alpine
ENTRYPOINT ["/entrypoint"]
COPY install_python.sh /
RUN /install_python.sh
