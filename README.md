# Configs_controller
bash script for manage configs file

Usage: Configs_controller [-p|-c|-d] [CONFIGS]

Synchronize configuration files

There is three mode that control what to do with the configs.
-  -c, --collect  Update the files in the collection to match the current
                  configs on the system
-  -p, --place    Place configuration files from the collection in the system
-  -d, --diff     Show differences between configs in collection and in system

-  -h, --help     display this help and exit

If no config is specified, the script works for all at once. You can specify
specific config files

-   --vim        for directory .vim (script can make symbolic link)
-   --alacritty  for .alacritty.yml
-   --i3         for directory .i3 (script can make symbolic link)
-   -a, --all    for all at once

