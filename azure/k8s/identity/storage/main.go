package main

import (
	"context"
	"fmt"
	"log"
	"os"

	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/Azure/azure-sdk-for-go/sdk/storage/azblob"
)

func main() {
	clientID := os.Getenv("AZURE_CLIENT_ID")
	tenantID := os.Getenv("AZURE_TENANT_ID")
	tokenFilePath := os.Getenv("AZURE_FEDERATED_TOKEN_FILE")

	storageUrl := os.Getenv("STORAGE_URL")

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

	client, err := azblob.NewClient(storageUrl, credential)
	if err != nil {
		log.Fatalf("could not create access token provider: %v", err)
	}

	containers := client.NewListContainersPager(nil)
	for containers.More() {
		page, err := containers.NextPage(context.TODO())
		if err != nil {
			log.Fatal(err)
		}

		for _, c := range page.ContainerItems {
			fmt.Printf("Name: %s", *c.Name)
		}
	}
}
