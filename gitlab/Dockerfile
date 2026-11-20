# GitLab CE on Railway: the official Omnibus image, pinned, with /etc/gitlab (gitlab.rb and gitlab-secrets.json)
# kept on the one volume a Railway service gets, the root password set at deploy and sign-up turned off.
ARG GITLAB_VERSION=19.6.1-ce.0
FROM gitlab/gitlab-ce:${GITLAB_VERSION}
COPY railway-start.sh /railway-start.sh
CMD ["/bin/bash", "/railway-start.sh"]
