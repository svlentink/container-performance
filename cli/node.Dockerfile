FROM alpine
ENTRYPOINT ["/entrypoint"]
COPY install_node.sh /
RUN /install_node.sh
