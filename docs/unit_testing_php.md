# Overview
To do unit testing for php scripts, we will be using `phpunit`.

https://phpunit.de/documentation.html

# Setup
### Step 1: Windows
1. Get the PHP zip by using this link: https://windows.php.net/download/.
2. Download the Non Thread Safe version, and extract it into a directory like C:/php.
3. Add PHP to your environment variables and verify using `php --version` in Windows CLI.
4. Go to the php foder and go into php.ini, and uncomment / add `extension=phar` and `extension=mbstring`.

### Step 1: Ubuntu
```
sudo apt update
sudo apt install php-cli \
                 php-json \
                 php-mbstring \
                 php-xml \
                 php-pcov \
                 php-xdebug
```
### Step 2: Both
1. Create a tools folder and tests folder at the root of the project (will be used later).
2. Using wsl / ubuntu, navigate to the root of the project and download the phpunit php archive (.phar)
```
wget -O phpunit.phar https://phar.phpunit.de/phpunit-10.phar
chmod +x phpunit.phar
mv phpunit.phar tools
```
3. Change these settings in the php.ini:
```
error_reporting=-1
xdebug.show_exception_trace=0
xdebug.mode=coverage
zend.assertions=1
assert.exception=1
memory_limit=-1
```

# Writing Tests
## Useful Links
1. [phpunit - Writing Tests](https://docs.phpunit.de/en/11.3/writing-tests-for-phpunit.html)
2. [phpunit - Assertions](https://docs.phpunit.de/en/11.3/assertions.html#appendixes-assertions)

## Usage
Classes that need to be tested will be given a suffix `~Test`, and will inherit from `TestCase`

Example: \
The tests for a class e.g. `Bullet` will go into a class called `BulletTest`. \
`BulletTest` will inherit from `TestCase`.

Below is an example where `Greeting.php` is created in `src/Greeting.php` and `GreetingTest` is created in `tests/GreetingTests.php`
```php
<?php declare(strict_types=1);
final class Greeting
{
    public function greet(string $name): string
    {
        return 'Hello, ' . $name . '!';
    }
}
```
```php
<?php declare(strict_typees=1);
use PHPUnit\Framework\TestCase;

final class GreetingTest extends TestCase
{
    public function testGreeting() : void
    {
        // ...
    }
}
```
To write a `test` function, there are two ways of doing it:
```php
<?php declare(strict_types=1);
use PHPUnit\Framework\Attributes\Test;
use PHPUnit\Framework\TestCase;

final class ExampleTest extends TestCase
{
    // Method 1 - Use a #[Test] Attribute
    #[Test]
    public function it_does_something(): void
    {
        // ...
    }

    // Method 2 - Use a test prefix
    public function testItDoesSomething() : void
    {
        // ...
    }
}
```
To check for results, use assertions:
```php
<?php declare(strict_typees=1);
use PHPUnit\Framework\TestCase;
require __DIR__ . '/../src/Greeter.php';

final class GreetingTest extends TestCase
{
    public function testGreeting() : void
    {
        $greeting = new Greeting;

        $words = $greeting->greet('Alice');

        // Checks whether the output is the same.
        $this->assertSame('Hello, Alice!', $words);
    }
}
```

## Testing
Run the php scripts in the `tests` folder using `php ./tools/phpunit.phar path/to/test/file.php`
