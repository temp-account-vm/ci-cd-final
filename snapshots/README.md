# Snapshots

Ce dossier contient les snapshots créés automatiquement via le workflow GitHub Actions.

## Fonctionnement

Lors de l'exécution du workflow, si toutes les étapes précédentes (notamment Terraform) se terminent sans erreur, une snapshot du disque de la VM est créée automatiquement. Le nom du snapshot suit le format `deploy-staging-YYYYMMDDHHMMSS`.

L'étape concernée dans le workflow ressemble à ceci :

```yaml
- name: Create Snapshots
    if: success()
    run: |
        echo "Creating snapshots of the VM disk"

        DISK_NAME=${{ env.DISK_NAME }}
        echo "Boot disk name: $DISK_NAME"

        if [ -z "$DISK_NAME" ]; then
            echo "No boot disk name found, cannot create snapshot"
            exit 1
        fi

        SNAPSHOT_NAME="deploy-staging-$(date +%Y%m%d%H%M%S)"

        gcloud compute disks snapshot "$DISK_NAME" \
            --zone="$GOOGLE_ZONE" \
            --project="$GOOGLE_PROJECT" \
            --snapshot-names="$SNAPSHOT_NAME" \
            --quiet

        echo "SNAPSHOT_NAME=$SNAPSHOT_NAME" >> $GITHUB_ENV
```

## Remarques

- Les snapshots ne sont créés que si aucune erreur n'est survenue avant cette étape.
- Le disque cloné correspond à la VM déployée par Terraform.