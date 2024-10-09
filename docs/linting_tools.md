| Table of Contents |
|:-:|
|[PHP_CodeSniffer](#php_codesniffer)|



## [PHP_CodeSniffer](https://github.com/PHPCSStandards/PHP_CodeSniffer/)

### Requirements
- PHP >= 5.4.0
    Installation (ubuntu):
    ```
    sudo apt install php-cli
    ```

### Installation
```
# download using curl
curl -OL https://phars.phpcodesniffer.com/phpcs.phar
curl -OL https://phars.phpcodesniffer.com/phpcbf.phar

# or download using wget
wget https://phars.phpcodesniffer.com/phpcs.phar
wget https://phars.phpcodesniffer.com/phpcbf.phar

# test phars using
php phpcs.phar -h
php phpcbf.phar -h
```

### Usage
Checking against PEAR coding standard (file): `phpcs /path/to/code/file.php` \
Checking against PEAR coding standard (directory): `phpcs /path/to/directory` \
Checking against PSR-12 coding standard: `phpcs --standard=PSR12 /path/to/directory`

## [ReSharper](https://www.jetbrains.com/help/resharper/ReSharper_Command_Line_Tools.html)

### Requirements
- .NET >= 3.1.0 \
    Installation (ubuntu):
    ```
    apt-get update && apt-get install -y \
    wget \
    && wget https://dot.net/v1/dotnet-install.sh \
    && bash dotnet-install.sh --channel 6.0 \
    && rm dotnet-install.sh
    ```

### Installation
__Global Installation:__
```
dotnet tool install -g JetBrains.ReSharper.GlobalTools
```

__Local Installation:__
```
# Used in build script, using a tool manifest file
# one time locally
dotnet new tool-manifest
dotnet tool install JetBrains.ReSharper.GlobalTools

# In the build script
dotnet tool restore
```

### Usage
To find code issues in a solution: `jb inspectcode YourSolution.sln -o=<PathToOutputFile>` \
To find code issues in a directory: `jb inspectcode /Path/To/Directory -o=<PathToOutputFile>` \
To reformat code and fix code style in a solution: `jb cleanupcode YourSolution.sln`

For more command line parameters:
https://www.jetbrains.com/help/resharper/InspectCode.html#command-line-parameters