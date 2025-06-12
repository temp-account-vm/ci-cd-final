#!/bin/bash
set -e

npx standard-version

git push --follow-tags origin main