#!/bin/bash

set -e

if [ ! -z "$WALLARM_API_TOKEN" ]; then
    echo "WALLARM_API_TOKEN is set, checking configuration"
    if [[ $DYNO == web.* ]]; then
        echo "Heroku dyno type [$DYNO] is 'web', running Wallarm configuration scripts"
        # Configure PORT in nginx config
        sed -i "s/\$PORT/$PORT/g" /etc/nginx/nginx.conf
        # Register Wallarm node in the Cloud
        /opt/wallarm/register-node --token "$WALLARM_API_TOKEN" -H "$WALLARM_API_HOST" --labels "$WALLARM_LABELS"
        # Read default Wallarm environment variables
        export $(sed -e 's/=\(.*\)/="\1"/g' /opt/wallarm/env.list | grep -v "#" | xargs)
        # Export $PORT as $NGINX_PORT (required for the `export-metrics` script)
        export NGINX_PORT="$PORT"
        export -n TT_MEMTX_MEMORY
        # Read user-set Wallarm variables
        # [ -s /etc/wallarm-override/env.list ] && export $(sed -e 's/=\(.*\)/="\1"/g' /etc/wallarm-override/env.list | grep -v "#" | xargs)
        # Launch all Wallarm services and NGINX under supervisord in the background
        /opt/wallarm/usr/bin/python3.10 /opt/wallarm/usr/bin/supervisord -c /opt/wallarm/etc/supervisord.conf
else
    echo "Heroku dyno type [$DYNO] is not 'web', skipping Wallarm configuration"
    fi
else
    echo "WALLARM_API_TOKEN is not set, just executing CMD"
fi

# Execute the CMD command
exec "$@"
