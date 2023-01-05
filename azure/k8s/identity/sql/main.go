package main

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"os"

	"github.com/Azure/azure-sdk-for-go/sdk/azcore/policy"
	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	mssql "github.com/microsoft/go-mssqldb"
)

func main() {
	clientID := os.Getenv("AZURE_CLIENT_ID")
	tenantID := os.Getenv("AZURE_TENANT_ID")
	tokenFilePath := os.Getenv("AZURE_FEDERATED_TOKEN_FILE")

	server := os.Getenv("SQL_SERVER")
	dbName := os.Getenv("SQL_DB")

	var connectionString = fmt.Sprintf("server=%s;user id=%s; database=%s", server, clientID, dbName)

	connection, err := mssql.NewConnectorWithAccessTokenProvider(connectionString, func(ctx context.Context) (string, error) {
		credential, err := azidentity.NewClientAssertionCredential(tenantID, clientID, func(ctx context.Context) (string, error) {
			content, err := os.ReadFile(tokenFilePath)
			if err != nil {
				return "", err
			}

			return string(content), nil
		}, nil)
		if err != nil {
			log.Fatal(err)
		}

		token, err := credential.GetToken(ctx, policy.TokenRequestOptions{
			Scopes: []string{"https://database.windows.net/.default"},
		})
		if err != nil {
			return "", err
		}

		return token.Token, nil
	})

	if err != nil {
		log.Fatalf("could not create access token provider: %v", err)
	}
	db := sql.OpenDB(connection)

	if err = db.PingContext(context.Background()); err != nil {
		log.Fatalf("could not ping database: %v", err)
	}
	log.Println("connected")
}
