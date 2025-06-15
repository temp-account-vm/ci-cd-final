# Rollback Automatique via GitHub Actions

Ce projet intègre un mécanisme de rollback automatique en cas d'échec du déploiement grâce à une GitHub Action dédiée.

Lorsqu'une erreur survient après l'application de Terraform, la GitHub Action suivante restaure automatiquement le disque à partir du dernier snapshot réussi :

```yaml
- name: Rollback on failure
    if: failure() && steps.terraform_apply.outcome == 'success'
    run: |
        echo "Rolling back to the last successful snapshot"

        LAST_SNAPSHOT=$(gcloud compute snapshots list \
            --filter="name~'deploy-production'" \
            --sort-by="~creationTimestamp" \
            --limit=1 \
            --format="value(name)")

        if [ -z "$LAST_SNAPSHOT" ]; then
            echo "No previous snapshot found, cannot rollback"
            exit 1
        fi

        DISK_NAME=${{ env.DISK_NAME }}
        echo "Boot disk name: $DISK_NAME"

        if [ -z "$DISK_NAME" ]; then
            echo "No boot disk name found, cannot rollback"
            exit 1
        fi

        gcloud compute disks create "$DISK_NAME" \
            --source-snapshot="$LAST_SNAPSHOT" \
            --zone="$GOOGLE_ZONE" \
            --project="$GCP_PROJECT_ID" \
            --quiet

        echo "Rolled back to snapshot: $LAST_SNAPSHOT"
```

## Fonctionnement

- En cas d'échec, le workflow recherche le dernier snapshot
- Si un snapshot est trouvé, il restaure automatiquement le disque de boot à partir de ce snapshot.
- Si aucun snapshot n'est disponible, le rollback est impossible et le processus s'arrête.
