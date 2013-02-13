**This repository contains shell scripts for helping setup Jenkins to build and deploy WebObjects applications.**

When combined with the corresponding Jenkins jobs (Jobs available in seperate repositories) these scripts can:

1. **Apple WebObjects™**: <br />
  a) 5.4.3 from Apple <br />
  b) Install it in a version-specific location that will not conflict with other WebObjects installs - JENKINS_HOME/WOFrameworksRepository/WebObjects/VERSION

2. **Project WOnder**:<br />
  a) Clone Project WOnder from the github.com repository<br />
  b) Build 'integration'<br />
  c) Install in JENKINS_HOME/WOFrameworksRepository/ProjectWOnder/integration<br />

3. **WOdka**:<br />
  a) Clone WOdka from the github.com repository<br />
  b) Build by the Jenkins job<br />
  c) Install in JENKINS_HOME/WOFrameworksRepository/WOdka/<br />

3. Add any frameworks required by your project (based on the .classpath file) into your project's workspace (using symbolic links)<br />
  a) WebObjects 5.4.3 frameworks<br />
  b) Project WOnder 'integration' frameworks<br />
  c) WOdka frameworks<br />

4. Build your WebObjects Framework or Application

5. Deploy you WebObjects Application to a remote server running Wonder's JavaMonitor and wotaskd.

following Repo you will need :<br /><br />
* [Install WO & WOnder](https://github.com/ishimoto/WOJenkins_Job_InstallWOAndWOnder.git)
* [Install WOdka](https://github.com/ishimoto/WOJenkins_Job_InstallWOdka.git)
* [Build your Apps](https://github.com/ishimoto/WOJenkins_Job_WOProject_Git.git)

---

#####This script is a slightly different version, please use the wonder version.

* remove of WO 5.3.3 support
* wonder is default to 'integration' repo
* support for WOdka APP installations