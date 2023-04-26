#!/usr/bin/env python3

import json
import os

file_paths = [
    "/Applications/VSCodium.app/Contents/Resources/app/product.json"
]

fileChanged = False

for path in file_paths:
    print('Checking for file: {}'.format(path))
    if os.path.isfile(path):
        with open(path, "r") as f:
            config = json.load(f)
            config["extensionsGallery"]["serviceUrl"] = "https://marketplace.visualstudio.com/_apis/public/gallery"
            config["extensionsGallery"]["cacheUrl"] = "https://vscode.blob.core.windows.net/gallery/index"
            config["extensionsGallery"]["itemUrl"] = "https://marketplace.visualstudio.com/items"

        with open(path, "w") as f:
            json.dump(config, f, indent=2)

        print('  Changed marketplace in {}'.format(path))
        fileChanged = True

if not fileChanged:
    print('Warning: No marketplaces could be found to be changed')
    exit(1)