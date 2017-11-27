from alpine
CMD ["/entrypoint"]
COPY install-lamp.sh /
RUN /install-lamp.sh
