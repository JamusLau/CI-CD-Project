`Unity.exe -runTests -batchmode -projectPath PATH_TO_YOUR_PROJECT -testResults C:\temp\results.xml -testPlatform WebGL`
https://docs.unity3d.com/Packages/com.unity.test-framework%401.1/manual/reference-command-line.html

# Unity Test Framework
1. Ensure that there is a folder named `Tests` in the Unity project folder.
2. Ensure that the test scripts are using NUnit attributes like `[Test]` and `[TestFixture]`
