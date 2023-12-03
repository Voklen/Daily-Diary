#!/usr/bin/env python3

import sys
from ruamel.yaml import YAML


def update_pubspec(new_ver):
    yaml = YAML()
    yaml.preserve_quotes = True
    yaml.width = 100

    with open('pubspec.yaml', 'r') as f:
        y = yaml.load(f)

    parts = y['version'].split('+')
    build_number = int(parts[1]) + 1
    y['version'] = f'{new_ver}+{build_number}'

    with open('pubspec.yaml', 'w') as f:
        yaml.dump(y, f)


update_pubspec(sys.argv[1])
