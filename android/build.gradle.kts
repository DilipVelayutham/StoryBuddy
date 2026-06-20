allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

subprojects {
    fun configureProject(proj: Project) {
        val androidExt = proj.extensions.findByName("android")
        if (androidExt != null) {
            var success = false
            // Try compileSdkVersion(int)
            try {
                val method = androidExt.javaClass.getMethod("compileSdkVersion", Int::class.javaPrimitiveType)
                method.invoke(androidExt, 34)
                success = true
            } catch (e: Exception) {}
            
            // Try setCompileSdkVersion(int)
            if (!success) {
                try {
                    val method = androidExt.javaClass.getMethod("setCompileSdkVersion", Int::class.javaPrimitiveType)
                    method.invoke(androidExt, 34)
                    success = true
                } catch (e: Exception) {}
            }

            // Try compileSdkVersion(String)
            if (!success) {
                try {
                    val method = androidExt.javaClass.getMethod("compileSdkVersion", String::class.java)
                    method.invoke(androidExt, "android-34")
                    success = true
                } catch (e: Exception) {}
            }
        }
    }
    if (project.state.executed) {
        configureProject(project)
    } else {
        project.afterEvaluate {
            configureProject(this)
        }
    }
}
