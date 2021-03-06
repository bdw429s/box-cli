component extends="mxunit.framework.TestCase" {
//component extends="testbox.system.testing.TestBox" {

	candidates = createObject("java","java.util.TreeSet");

	public void function setUp()  {
		var shell = new commandbox.system.Shell();
		commandHandler = new commandbox.system.CommandHandler(shell);
	}

	public void function testInitCommands()  {
		var commands = commandHandler.getCommands();
		assertTrue(structKeyExists(commands,"quit"));
	}

	public void function testHelpCommands()  {
		commandChain = commandHandler.resolveCommand( "coldbox help" );
		assertTrue(commandChain[1].commandString == 'help');
	}
	
	public void function testResolveCommand()  {
		commandChain = commandHandler.resolveCommand( "help | more" );
		assertTrue(commandChain.len() == 2);
	}
		
	public void function testRunCommandLine()  {
		result = commandHandler.runCommandLine( "help | more" );
	}

	/*
	<cfsavecontent variable="command">
	brad test foobar 
	"goo" 
	'doo' 
	 "this is a test" 
	      test\"er 
	      12\=34
	</cfsavecontent>
		<!---
	<cfsavecontent variable="command">
	brad test 
	param=1 
	arg="no"
	 me='you' 
	  arg1="brad wood" 
	  arg2="Luis \"The Dev\" Majano" 
	  test  =  		 mine 	 
	   tester   	=  	 'YOU' 	
	     tester2   	=  	 "YOU2"
	</cfsavexcontent>
		--->
		
		
	#command#<br><br><br>*/

}