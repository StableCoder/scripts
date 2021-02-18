#!/usr/bin/env python

import json

# This works at least for Arch Linux's 'Code - OSS'

file_path = "/usr/lib/code/product.json"

with open(file_path, "r") as f:
    config = json.load(f)
    config["extensionsGallery"]["serviceUrl"] = "https://marketplace.visualstudio.com/_apis/public/gallery"
    config["extensionsGallery"]["cacheUrl"] = "https://vscode.blob.core.windows.net/gallery/index"
    config["extensionsGallery"]["itemUrl"] = "https://marketplace.visualstudio.com/items"

with open(file_path, "w") as f:
    json.dump(config, f, indent=2)
