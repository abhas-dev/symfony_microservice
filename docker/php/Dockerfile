FROM dunglas/frankenphp

# Arguments pour l'utilisateur
ARG USER_ID=1000
ARG GROUP_ID=1000
ARG USER_NAME=developer

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    zip \
    unzip \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install Symfony CLI
RUN curl -sS https://get.symfony.com/cli/installer | bash && \
    mv /root/.symfony*/bin/symfony /usr/local/bin/symfony

# Configure Git globally to avoid ownership issues
RUN git config --global --add safe.directory '*' && \
    git config --global init.defaultBranch main && \
    git config --global user.email "docker@example.com" && \
    git config --global user.name "Docker User"

# Create user with same UID/GID as host user
RUN groupadd -g ${GROUP_ID} ${USER_NAME} || true && \
    useradd -u ${USER_ID} -g ${GROUP_ID} -m -s /bin/bash ${USER_NAME} || true && \
    echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set working directory
WORKDIR /app

# Create php.ini with optimized settings
RUN echo "memory_limit = 512M" > /usr/local/etc/php/php.ini && \
    echo "upload_max_filesize = 50M" >> /usr/local/etc/php/php.ini && \
    echo "post_max_size = 50M" >> /usr/local/etc/php/php.ini && \
    echo "max_execution_time = 300" >> /usr/local/etc/php/php.ini

# Change ownership to our user
RUN chown -R ${USER_ID}:${GROUP_ID} /app && \
    mkdir -p /data /config && \
    chown -R ${USER_ID}:${GROUP_ID} /data /config

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Switch to our user
USER ${USER_NAME}

ENTRYPOINT ["docker-entrypoint.sh"]