#!/bin/bash

ENV_FILE=".env"
POSTGRES_USER="postgres"
POSTGRES_DB="ios_db"
JWT_ISSUER="backend"
JWT_AUDIENCE="ios-app"
APPLE_BUNDLE_ID="ios.Assignment3"

if [ ! -f "$ENV_FILE" ]; then
    echo "Creating $ENV_FILE with freshly generated secrets..."
    DB_PASSWORD=$(openssl rand -base64 24 | tr -d '+/=' | cut -c1-16)
    JWT_SECRET=$(openssl rand -base64 48 | tr -d '+/=' | cut -c1-64)

    cat <<EOF > $ENV_FILE
POSTGRES_USER=$POSTGRES_USER
POSTGRES_PASSWORD=$DB_PASSWORD
POSTGRES_DB=$POSTGRES_DB
JWT_SECRET=$JWT_SECRET
JWT_ISSUER=$JWT_ISSUER
JWT_AUDIENCE=$JWT_AUDIENCE
APPLE_BUNDLE_ID=$APPLE_BUNDLE_ID
EOF
    echo "✅ Secrets generated and saved to $ENV_FILE"
else
    echo "ℹ️  $ENV_FILE already exists. Loading existing values..."
fi

# Load the variables safely without executing them as commands
if [ -f "$ENV_FILE" ]; then
    # This reads the file line by line and exports each one
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip comments and empty lines
        [[ $line =~ ^#.*$ ]] && continue
        [[ -z $line ]] && continue
        export "$line"
    done < "$ENV_FILE"
fi

echo "Syncing with .NET User Secrets..."
dotnet user-secrets set "ConnectionStrings:DefaultConnection" "Host=127.0.0.1;Port=5432;Database=$POSTGRES_DB;Username=$POSTGRES_USER;Password=$POSTGRES_PASSWORD"
dotnet user-secrets set "Jwt:Secret" "$JWT_SECRET"
dotnet user-secrets set "Jwt:Issuer" "$JWT_ISSUER"
dotnet user-secrets set "Jwt:Audience" "$JWT_AUDIENCE"
dotnet user-secrets set "Apple:BundleId" "$APPLE_BUNDLE_ID"

echo "🚀 Environment is ready for iOS Assignment!"
