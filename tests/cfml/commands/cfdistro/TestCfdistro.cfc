component name="TestShell" extends="mxunit.framework.TestCase" {

	workdir = expandPath("/tests/work");
	homedir = workdir & "/home";

	public void function beforeTests()  {
		shell = new commandbox.system.Shell();
		directoryExists(workdir) ? directoryDelete(workdir,true) : "";
		directoryCreate(workdir);
		directoryCreate(homedir);
		shell.cd(workdir);
		shell.setHomeDir(homedir);
		variables.cfdistroInstall = new commandbox.commands.cfdistro.install(shell);
		variables.cfdistroDependency = new commandbox.commands.cfdistro.dependency(shell);
	}

	public void function testInstall()  {
		cfdistroInstall.run();
	}

	public void function testDependency()  {
		var result = cfdistroDependency.run(groupId="org.mxunit",artifactId="core",version="2.1.3",mapping="/mxunit");
		//request.debug(result);
		//assertTrue(directoryExists(shell.getArtifactsDir() & "/org/mxunit/"));
	}


}