# Building Projects

## Unity (with CLI)

### Usage
1. Ensure a script is created within the project itself, providing the build methods.

```cs
using UnityEditor;
using UnityEngine;
using System.Collections;

public class BuildScript : MonoBehaviour
{
    public static void PerformWindowsBuild()
    {
        string[] scenes = { "Assets/Scene1.unity", "..." };
        // Target Platform: StandaloneWindows64
        BuildPipeline.BuildPlayer(scenes, "Builds/Application.exe", BuildTarget.<target_platform>, BuildOptions.None);
    }

    public static void PerformLinuxBuild()
    {
        ...
    }
}
```

2. Run the command, pointing to the function
`"C:\Path\To\Unity\Editor\Unity.exe" -quit -batchmode -projectPath "path/to/project" -buildTarget <platform> -executeMethod <ScriptMethod> -logFile "path/to/file.log"`
Available build targets:
- win64
- win
- linux64
- webgl

### References
https://docs.unity3d.com/Manual/EditorCommandLineArguments.html


## Unity (With Jenkins)


### References
https://nagachiang.github.io/gitlab-ci-building-unity-projects-automatically/#
https://www.robinryf.com/blog/2017/09/30/running-unity-inside-docker.html
https://game.ci
https://game.ci/docs/github/activation/#personal-license
