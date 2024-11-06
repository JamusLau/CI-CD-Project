# Table of Contents
| Language | Tool |
|:-:|:-:|
|PHP|[PHP_CodeSniffer](#php_codesniffer)|
|PHP|[PHPStan](#phpstan)|
|.NET|[ReSharper Global Tools](#resharper-global-tools)|
|.NET|[Roslyn Analyzers](#roslyn-analyzers)|
|JavaScript|[ESLint](#eslint)|


# [PHP_CodeSniffer](https://github.com/PHPCSStandards/PHP_CodeSniffer/)

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

or

`sudo apt install php-codesniffer`

### Usage
Checking against PEAR coding standard (file): `phpcs /path/to/code/file.php` \
Checking against PEAR coding standard (directory): `phpcs /path/to/directory` \
Checking against PSR-12 coding standard: `phpcs --standard=PSR12 /path/to/directory`
Checking the files without using a standard, only syntax: `phpcs --standard=Generic --sniffs=Generic.PHP.Syntax /path/`

# [PHPStan](#https://phpstan.org/user-guide/getting-started)
### Requirements
- Composer

### Installation
1. Require PHPStan in Composer: `composer require --dev phpstan/phpstan`

### Usage
1. (FIRST RUN) Point PHPStan to your code base: `vendor/bin/phpstan analyse src tests path`
2. Use `vendor/bin/phpstan [options] [<paths>...]` to analyse code, return 0 means no error.

# [ReSharper Global Tools](https://www.jetbrains.com/help/resharper/ReSharper_Command_Line_Tools.html)

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

# [Roslyn Analyzers](https://github.com/dotnet/roslyn-analyzers)
### Requirements
- NET SDK 6.0

### Installation
1. Add analyzers to your project in the `.csproj` file as NuGet packages
   ```xml
   <ItemGroup>
    <PackageReference Include="Microsoft.CodeAnalysis.NetAnalyzers" Version="7.0.0" />
   </ItemGroup>
   ```

### Usage
1. During build step of pipeline, ensure that the solution is restored and built:
    - `dotnet restore YourSolution.sln`
    - `dotnet build YourSolution.sln`
    - `dotnet build YourSolution.sln /p:RunAnalyzers=true`


# [ESLint](https://eslint.org/)
### Requirements
