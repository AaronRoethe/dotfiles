# Simulates a new user's first setup on a clean machine. See ../../.github/README.md (Testing).
FROM debian:bookworm-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends zsh git jq curl ca-certificates procps file \
 && rm -rf /var/lib/apt/lists/*

# gitleaks, which the Claude Code hooks use
ARG GITLEAKS_VERSION=8.30.1
RUN arch="$(dpkg --print-architecture | sed 's/amd64/x64/')" \
 && curl -fsSL "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_${arch}.tar.gz" \
  | tar -xz -C /usr/local/bin gitleaks

# macOS-only tools and slow runtime installs are stubbed; every call is logged to ~/stub.log.
# The mounted dotfiles repo is owned by the host uid. Set safe.directory system-wide so ~/.gitconfig stays untouched for the checkout.
RUN git config --system --add safe.directory '*'

COPY stubs/ /opt/stubs/
RUN chmod +x /opt/stubs/*

# Non-root user (Homebrew refuses root). Pre-create the Linux Homebrew prefix so its installer needs no sudo.
RUN useradd -m -s /bin/zsh newuser && mkdir -p /home/linuxbrew && chown newuser /home/linuxbrew
USER newuser
WORKDIR /home/newuser
ENV PATH=/opt/stubs:$PATH NONINTERACTIVE=1 HOMEBREW_NO_ANALYTICS=1 HOMEBREW_NO_AUTO_UPDATE=1

COPY --chown=newuser e2e.sh /opt/e2e.sh
CMD ["zsh", "/opt/e2e.sh"]
