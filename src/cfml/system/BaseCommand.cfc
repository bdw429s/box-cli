/**
* I am the base command implementation.  An abstract class if you will.
**/
component {
	
	// Carriadge return
	cr = chr(10);
	
	function init(shell) {
		variables.shell = shell;
		variables.fileSystemUtil = new commandbox.system.util.FileSystem( shell );
		variables.ANSIUtil = new commandbox.system.util.ANSI();
		print = new commandbox.system.util.PrintBuffer( shell );
		hasErrored = false;
		return this;
	}
	
	// This method needs to be overridden by the concrete class.
	function run() {
		return 'This command CFC has not implemented a run() method.';
	}
	
	// Called prior to each execution to reset any state stored in the CFC
	function reset() {
		print.clear();
		hasErrored = false;
	}
		
	// Get the result.  This will be called if the run() method doesn't return anything
	function getResult() {
		return print.getResult();
	}
			
	/**
	 * Ask the user a question and wait for response
	 * @message.hint message to prompt the user with
 	 **/
	function ask( required message ) {
		return shell.ask( message );
	}
		
	/**
	 * Wait until the user's next keystroke
	 * @message.hint An optional message to display to the user such as "Press any key to continue."
 	 **/
	function waitForKey( required message ) {
		return shell.waitForKey( message );
	}
		
	/**
	 * Run another command by name. 
	 * @command.hint The command to run. Pass the same string a user would type at the shell.
 	 **/
	function runCommand( required command ) {
		return shell.callCommand( command );
	}

		
	/**
	 * Use if if your command wants to give contorlled feedback to the user without raising
	 * an actual exception which comes with a messy stack trace.  "return" this command to stop execution of your command
	 * Alternativley, multuple errors can be printed by calling this method more than once prior to returning.
	 * Use clearPrintBuffer to wipe out any output accrued in the print buffer. 
	 * 
	 * return error( "We're sorry, but happy hour ended 20 minutes ago." );
	 *	 
	 * @message.hint The error message to display
 	 **/
	function error( required message, clearPrintBuffer=false ) {
		hasErrored = true;
		if( clearPrintBuffer ) {
			// Wipe 
			print.clear();
		} else {
			// Distance ourselves from whatever other output the command may have given so far.
			print.line();
			print.line();
		}
		print.whiteOnRedLine( 'ERROR' );
		print.line();
		print.redLine( message );
		print.line();
		
	}
	
	/**
	 * Tells you if the error() method has been called on this command.  Useful if you have several validation checks, and then want
	 * to return at the end if one of them failed.
 	 **/
	function hasError() {
		return hasErrored;
	}

			
}