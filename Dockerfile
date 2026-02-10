# Container image that runs your code
FROM ghcr.io/loonwerks/inspecta-verus-ci-action-container:0.2026.01.30.44ebdee

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
