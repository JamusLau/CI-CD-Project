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


## Unity (With Jenkins Locally)
This method builds the Unity project locally on your machine where Unity is installed. This exists as building within an agent-image within Jenkins doesn't work, since manual verification of licenses no longer work for personal licenses. Therefore, this method will create a Java server on your local machine, which listens to a HTTP request (a trigger) from Jenkins to trigger a build. Use this method if you have no other way and only if:
- You are using Unity personal
- You are using Jenkins locally in a Docker container

The idea is that after testing and when the Jenkins build project runs, a HTTP request is sent to the Java server, letting the server know that the project is ready to be built, using a certain trigger word. The project is then pulled from the repository, and built locally on the host machine using Unity personal.

### Requirements
- Unity
- Java
- Jenkins

### Setup
1. Install Unity locally on your machine.
2. (Optional) Add Unity to your PATH to be able to call it easily.
3. Install the `HTTP Request` plugin on Jenkins.
4. Ensure that the Jenkins instance within Docker can communicate with the host.
   - Add this line when you start the Jenkins container: `--add-host=host.docker.internal:host-gateway`

### Usage
1. Create a Java server to listen for HTTP Requests. Below is an example of a Java Server
   ```java
    import com.sun.net.httpserver.*;
    import java.io.*;
    import java.net.Inet4Address;
    import java.net.InetAddress;
    import java.net.InetSocketAddress;
    import java.util.HashMap;
    
    public class JenkinsListener {
        public static void main(String[] args) throws IOException {
            HttpServer server = HttpServer.create(new InetSocketAddress(8081), 0);
    
            server.createContext("/", new MyHandler());
            server.setExecutor(null);
            System.out.println("Starting server on port 8081");
            server.start();
            System.out.println("Server started on IPv4: " + Inet4Address.getLocalHost().getHostAddress());
        }
    
        static class MyHandler implements HttpHandler {
    
            //hash map to store list of all trigger words and paths to shell scripts
            private static final HashMap<String, String> triggerWordPaths = new HashMap<String, String>();
            static {
                triggerWordPaths.put("buildWindows", "./runWindowsBuild.sh");
                triggerWordPaths.put("testUnity", "./runUnityTests.sh");
            }
            
            @Override
            // handles requests
            public void handle(HttpExchange exchange) throws IOException {
                if ("POST".equals(exchange.getRequestMethod())) {
                    InputStreamReader reader = new InputStreamReader(exchange.getRequestBody());
                    BufferedReader bufferedReader = new BufferedReader(reader);
                    StringBuilder requestBody = new StringBuilder();
                    String line;
                    while ((line = bufferedReader.readLine()) != null) {
                        requestBody.append(line);
                    }
                    String requestBodyString = requestBody.toString();
                    System.out.println("Received POST request: " + requestBody.toString());
    
                    // check whether the request body contains the required text to build
                    String responseMessage = "";
                    int responseCode = 0;
    
                    // checks for trigger word if exist, then run shell script if exist
                    if (triggerWordPaths.containsKey(requestBodyString)) {
                        responseCode = 200;
                        int success = runShellScript(triggerWordPaths.get(requestBodyString));
                        
                        // return a response based on the exit code to Jenkins, so Jenkins can mark it as success / failure
                        if (success == 0) {
                            responseMessage = "Status of request of [" + requestBodyString + "] is [SUCCESS]";
                        } else {
                            responseMessage = "Status of request of [" + requestBodyString + "] is [FAILURE]";
                        }
                    }
                    
                    // sends the response after it has been set
                    exchange.sendResponseHeaders(responseCode, responseMessage.length());
                    OutputStream os = exchange.getResponseBody();
                    os.write(responseMessage.getBytes());
                    os.close();
                } else {
                    // returns error if no post request was deteceted
                    String response = "Only POST requests are accepted.";
                    exchange.sendResponseHeaders(405, response.length());
                    OutputStream os = exchange.getResponseBody();
                    os.write(response.getBytes());
                    os.close();
                }
            }
        }
    
        public static int runShellScript(String shellScriptPath) {
            ProcessBuilder processBuilder = new ProcessBuilder(shellScriptPath);
            processBuilder.redirectErrorStream(true);
            int exitCode = 1;
            try {
                Process process = processBuilder.start();
                
                //capture output from script
                InputStream iS = process.getInputStream();
                BufferedReader bR = new BufferedReader(new InputStreamReader(iS));
                // printing live output of the script line by line
                String scriptline;
                while ((scriptline = bR.readLine()) != null) {
                    System.out.println(scriptline);
                }
                // waitingfor exit code
                exitCode = process.waitFor();
                System.out.println("Script exited with code: " + exitCode);
            } catch (IOException | InterruptedException e) {
                System.err.println("Error executing script: " + e.getMessage());
            }
            return exitCode;
        }
    }
   ```
2. Compile and run the server using `javac JenkinsListener.java` & `java JenkinsListener`
3. Go to your Jenkins pipeline project.
   - Under `Build Steps`, add the `HTTP Request`.
   - Set the URL as `http://host.docker.internal:port` (port should be what you started the Java server on).
   - Set the mode to `POST`
   - Under Advanced, set the request body to any trigger word you want (should be the same as what you set in the server).
4. Create a shell script that will clone the repository and build the project using Unity:
   ```sh
    echo Building the windows build
    PROJECT_PATH="./Project"
    BUILD_PATH="./Build"
    
    if [ -d "$PROJECT_PATH" ]; then 
        echo "Removing old project folder"
        rm -rf "$PROJECT_PATH"
    fi
    
    if [ -d "$BUILD_PATH" ]; then 
        echo "Removing old project folder"
        rm -rf "$BUILD_PATH"
    fi
    
    echo Cloning the repo...
    git clone --branch Dev-Main --depth 1 https://username:password@git.gitlabproject.com/project.git ./Project
    echo Cloning into $PROJECT_PATH done...
    
    echo Building the project...
    Unity -nographics -batchmode -quit -projectPath "./Project/" -buildLinux64Player "../../Build/App.x86_64" -logFile "./Build/Build_Log.txt"
    echo Building is done...
    
    cd $BUILD_PATH
    
    echo Compiling Server zip
    cp App.x86_64 server.x86_64
    zip -r VCServer.zip server.x86_64 App_Data UnityPlayer.so
    rm server.x86_64
    echo Server zip compiling done
    
    echo Compiling Client zip
    cp App.x86_64 client.x86_64
    zip -r VCClient.zip client.x86_64 App_Data UnityPlayer.so
    rm client.x86_64
    echo Client zip compiling done
   ```

### References
https://nagachiang.github.io/gitlab-ci-building-unity-projects-automatically/# \
https://www.robinryf.com/blog/2017/09/30/running-unity-inside-docker.html \
https://game.ci \
https://game.ci/docs/github/activation/#personal-license \
