#!/bin/bash

ENV_FILE=".env"

if [ ! -f "$ENV_FILE" ]; then
    echo "Creating $ENV_FILE with freshly generated secrets..."
    DB_PASSWORD=$(openssl rand -base64 24 | tr -d '+/=' | cut -c1-16)
    JWT_SECRET=$(openssl rand -base64 48 | tr -d '+/=' | cut -c1-64)

    cat <<EOF > $ENV_FILE
POSTGRES_USER=postgres
POSTGRES_PASSWORD=$DB_PASSWORD
POSTGRES_DB=ios_db
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
dotnet user-secrets set "Jwt:Key" "$JWT_KEY"
dotnet user-secrets set "Jwt:Issuer" "$JWT_ISSUER"
dotnet user-secrets set "Jwt:Audience" "$JWT_AUDIENCE"

echo "🚀 Environment is ready for iOS Assignment!"
