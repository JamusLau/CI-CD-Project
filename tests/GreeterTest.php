<?php declare(strict_types=1);
use PHPUnit\Framework\TestCase;
require __DIR__ . '/../src/Greeter.php';

final class GreeterTest extends TestCase
{
    public function testGreeting() : void
    {
        $greeting = new Greeter;

        $words = $greeting->greet('Alice');

        // Checks whether the output is the same.
        $this->assertSame('Hello, Alice!', $words);
    }
}