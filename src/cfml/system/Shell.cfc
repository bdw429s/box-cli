/**
*********************************************************************************
* Copyright Since 2005 ColdBox Platform by Ortus Solutions, Corp
* www.coldbox.org | www.ortussolutions.com
********************************************************************************
* @author Brad Wood, Luis Majano, Denny Valliant
* The CommandBox Shell Object that controls the shell
*/
component accessors="true"{

	/**
	* The java system class.
	*/
	property name="system";
	/**
	* The apache commons string utils
	*/
	property name="stringEscapeUtils";
	/**
	* The shell version number
	*/
	property name="version";

	/**
	 * constructor
	 * @inStream.hint input stream if running externally
	 * @printWriter.hint output if running externally
 	**/
	function init(inStream, printWriter) {

		// Version is stored in cli-build.xml. Build number is generated by Ant.
		// Both are replaced when CommandBox is built.
		variables.version = "@build.version@.@build.number@";

		variables.system = createObject( "java", "java.lang.System" );
		//variables.ANSIBuffer = createObject("java", "jline.ANSIBuffer");
		variables.stringEscapeUtils = createObject("java","org.apache.commons.lang.StringEscapeUtils");
		variables.atomicInteger = createObject( "java", "java.util.concurrent.atomic.AtomicInteger" ).init();
		variables.keepRunning = true;
		variables.reloadshell = false;
		variables.script = "";
		variables.initialDirectory = System.getProperty("user.dir");
		variables.pwd = initialDirectory;
		variables.cr = System.getProperty("line.separator");
		variables.print = new commandbox.system.util.Print();


		if(isNull(printWriter)) {
			if(findNoCase("windows",server.os.name)) {
				variables.ansiOut = createObject("java","org.fusesource.jansi.AnsiConsole").out;
        		var printWriter = createObject("java","java.io.PrintWriter").init(
        			createObject("java","java.io.OutputStreamWriter").init(variables.ansiOut,
        			// default to Cp850 encoding for Windows
        			System.getProperty("jline.WindowsTerminal.output.encoding", "Cp850"))
        			);
				var FileDescriptor = createObject("java","java.io.FileDescriptor").init();
		    	inStream = createObject("java","java.io.FileInputStream").init(FileDescriptor.in);
				reader = createObject("java","jline.ConsoleReader").init(inStream,printWriter);
			} else {
				//new PrintWriter(OutputStreamWriter(System.out,System.getProperty("jline.WindowsTerminal.output.encoding",System.getProperty("file.encoding"))));
		    	reader = createObject("java","jline.ConsoleReader").init();
			}
		} else {
			if(isNull(arguments.inStream)) {
		    	var FileDescriptor = createObject("java","java.io.FileDescriptor").init();
		    	inStream = createObject("java","java.io.FileInputStream").init(FileDescriptor.in);
			}
	    	reader = createObject("java","jline.ConsoleReader").init(inStream,printWriter);
		}
    	variables.homedir = env("user.home") & "/.CommandBox";
    	variables.tempdir = variables.homedir & "/temp";
		variables.shellPrompt = print.cyanText( "CommandBox> ");
		variables.commandHandler = new commandbox.system.CommandHandler(this);
		var completor = createDynamicProxy(new commandbox.system.Completor( commandHandler ), ['jline.Completor']);
        reader.addCompletor( completor );

		try {
			var historyFile = createObject("java", "java.io.File").init(homedir&"/.history");
			var history = createObject("java", "jline.History").init(historyFile);
			reader.setHistory(history);
			reader.setHistory(history);
		} catch (any e) {
// doesn't matter this is about to change with the other console
		}
		// counter for threads and stuff
    	return this;
	}

	/**
	 * returns the console reader
	 **/
	function getReader() {
    	return reader;
	}

	/**
	 * sets exit flag
	 **/
	function exit() {
    	keepRunning = false;
		return "Peace out!";
	}

	/**
	 * shell version
	 **/
/*	function version() {
		var versionFile = getDirectoryFromPath( getMetadata( this ).path ) & "/version";

		if( fileExists( versionFile ) ){
			return fileRead( versionFile );
		}

		return variables.version;
	}*/

	/**
	 * sets reload flag, relaoded from shell.cfm
	 * @clear.hint clears the screen after reload
 	 **/
	function reload(Boolean clear=true) {
		if(clear) {
			reader.clearScreen();
		}
		reloadshell = true;
    	keepRunning = false;
	}

	/**
	 * returns the current console text
 	 **/
	function getText() {
    	return reader.getCursorBuffer().toString();
	}

	/**
	 * sets prompt
	 * @text.hint prompt text to set
 	 **/
	function setPrompt(text="") {
		if(text eq "") {
			text = variables.shellPrompt;
		} else {
			variables.shellPrompt = text;
		}
		reader.setDefaultPrompt( variables.shellPrompt );
		return "set prompt";
	}

	/**
	 * ask the user a question and wait for response
	 * @message.hint message to prompt the user with
 	 **/
	function ask( message ) {
		var input = "";
		try {
			input = reader.readLine( message );
		} catch (any e) {
			printError( e );
		}
		reader.setDefaultPrompt( variables.shellPrompt);
		return input;
	}


	/**
	 * Wait until the user's next keystroke
	 * @message.message An optional message to display to the user such as "Press any key to continue."
 	 **/
	function waitForKey( message='' ) {
		var key = '';
		if( len( message ) ) {
			printString( message );
    		reader.flushConsole();
		}
		try {
			key = getReader().readVirtualKey();
		} catch (any e) {
			printError( e );
		}
		reader.setDefaultPrompt( variables.shellPrompt );
		return key;
	}

	/**
	 * clears the console
 	 **/
	function clearScreen() {
		reader.clearScreen();
		/*
		// Almost works on Windows, but doesn't
		// clear text backgroun
    	reader.printString( '[2J' );
    	reader.printString( '[1;1H' );
    	reader.flushConsole();
		*/
	}

	/**
	 * Get's terminal width
  	 **/
	function getTermWidth() {
       	return getReader().getTermwidth();
	}

	/**
	 * Get's terminal height
  	 **/
	function getTermHeight() {
       	return getReader().getTermheight();
	}

	/**
	 * Converts HTML into plain text
	 * @html.hint HTML to convert
  	 **/
	function unescapeHTML(required html) {
    	var text = StringEscapeUtils.unescapeHTML(html);
    	text = replace(text,"<" & "br" & ">","","all");
       	return text;
	}

	/**
	 * Converts HTML into ANSI text
	 * @html.hint HTML to convert
  	 **/
	function HTML2ANSI(required html) {
    	var text = replace(unescapeHTML(html),"<" & "br" & ">","","all");
    	var t="b";
    	if(len(trim(text)) == 0) {
    		return "";
    	}
    	var matches = REMatch('(?i)<#t#[^>]*>(.+?)</#t#>', text);
    	text = ansifyHTML(text,"b","bold");
    	text = ansifyHTML(text,"em","underline");
       	return text;
	}

	/**
	 * Converts HTML matches into ANSI text
	 * @text.hint HTML to convert
	 * @tag.hint HTML tag name to replace
	 * @ansiCode.hint ANSI code to replace tag with
  	 **/
	private function ansifyHTML(text,tag,ansiCode) {
    	var t=tag;
    	var matches = REMatch('(?i)<#t#[^>]*>(.+?)</#t#>', text);
    	for(var match in matches) {
    		var boldtext = print[ ansiCode ]( reReplaceNoCase(match,"<#t#[^>]*>(.+?)</#t#>","\1") );
    		text = replace(text,match,boldtext,"one");
    	}
    	return text;
	}

	/**
	 * returns the current directory
  	 **/
	function pwd() {
    	return pwd;
	}

	/**
	 * sets the shell home directory
	 * @directory.hint directory to use
  	 **/
	function setHomeDir(required directory) {
		variables.homedir = directory;
		setTempDir(variables.homedir & "/temp");
		return variables.homedir;
	}

	/**
	 * returns the shell home directory
  	 **/
	function getHomeDir() {
		return variables.homedir;
	}

	/**
	 * returns the shell artifacts directory
  	 **/
	function getArtifactsDir() {
		return getHomeDir() & "/artifacts";
	}

	/**
	 * sets and renews temp directory
	 * @directory.hint directory to use
  	 **/
	function setTempDir(required directory) {
        lock name="clearTempLock" timeout="3" {
        	try {
		        var clearTemp = directoryExists(directory) ? directoryDelete(directory,true) : "";
		        directoryCreate( directory );
		        variables.tempdir = directory;
        	} catch (any e) {
        		printError(e);
        	}
        }
    	return variables.tempdir;
	}

	/**
	 * returns the shell temp directory
  	 **/
	function getTempDir() {
		return variables.tempdir;
	}

	/**
	 * returns the enviroment property
  	 **/
	function env(required name) {
		var value = System.getProperty(name);
    	return isNull(value) ? "" : value;
	}

	/**
	 * changes the current directory
	 * @directory.hint directory to CD to
  	 **/
	function cd(directory="") {
		directory = replace(directory,"\","/","all");
		if(directory=="") {
			pwd = initialDirectory;
		} else if(directory=="."||directory=="./") {
			// do nothing
		} else if(directoryExists(directory)) {
	    	pwd = directory;
		} else {
			return "cd: #directory#: No such file or directory";
		}
		return pwd;
	}

	/**
	 * prints string to console
	 * @string.hint string to print (handles complex objects)
  	 **/
	function printString(required string) {
		if(!isSimpleValue(string)) {
			systemOutput("[COMPLEX VALUE]\n");
			writedump(var=string, output="console");
			string = "";
		}
    	reader.printString(string);
    	reader.flushConsole();
	}

	/**
	 * runs the shell thread until exit flag is set
	 * @input.hint command line to run if running externally
  	 **/
    function run(input="") {
        var mask = "*";
        var trigger = "su";
        reloadshell = false;

		try{
	        if (input != "") {
	        	input &= chr(10);
	        	var inStream = createObject("java","java.io.ByteArrayInputStream").init(input.getBytes());
	        	reader.setInput(inStream);
	        }
	        reader.setBellEnabled(false);

	        var line ="";
	        keepRunning = true;
			reader.setDefaultPrompt(shellPrompt);

			// set and recreate temp dir
			setTempDir(variables.tempdir);

	        while (keepRunning) {

				if(input != "") {
					keepRunning = false;
				}
				reader.printNewLine();
				try {
					// Shell stops on this line while waiting for user input
		        	line = reader.readLine();
				} catch (any er) {
					printError(er);
					continue;
				}

	            // If we input the special word then we will mask the next line.
	            if ((!isNull(trigger)) && (line.compareTo(trigger) == 0)) {
	                line = reader.readLine("password> ", javacast("char",mask));
	            }

	            // If there's input, try to run it.
				if( len(trim(line)) ) {

					try{
						callCommand(line);
					} catch (any e) {
						printError(e);
					}
				}

	        } // end while keep running

		} catch (any e) {
			printError(e);
		}
		return reloadshell;
    }

	/**
	 * call a command
 	 * @command.hint command name
 	 **/
	function callCommand( String command="" )  {
		var result = commandHandler.runCommandLine( command );
		if(!isNull( result ) && !isSimpleValue( result )) {
			if(isArray( result )) {
				return reader.printColumns(result);
			}
			result = formatJson(serializeJSON(result));
			printString( result & cr );
		} else if( !isNull( result ) ) {
			printString( result & cr );
		}
	}

	/**
	 * Get CommandHandler
 	 **/
	function getCommandHandler()  {
		return variables.commandHandler;
	}

	/**
	 * Get unique index (for thread naming and whatnot)
 	 **/
	public function getUniqueIndex() {
		return variables.atomicInteger.incrementAndGet();
	}

	/**
	 * Pretty JSON
 	 **/
	public function formatJson(json) {
		var retval = '';
		var str = json;
	    var pos = 0;
	    var strLen = str.length();
		var indentStr = '    ';
	    var newLine = cr;
		var char = '';

		for (var i=0; i<strLen; i++) {
			char = str.substring(i,i+1);
			if (char == '}' || char == ']') {
				retval &= newLine;
				pos = pos - 1;
				for (var j=0; j<pos; j++) {
					retval &= indentStr;
				}
			}
			retval &= char;
			if (char == '{' || char == '[' || char == ',') {
				retval &= newLine;
				if (char == '{' || char == '[') {
					pos = pos + 1;
				}
				for (var k=0; k<pos; k++) {
					retval &= indentStr;
				}
			}
		}
		return retval;
	}


	/**
	 * print an error to the console
	 * @err.hint Error object to print (only message is required)
  	 **/
	function printError(required err) {
		reader.printString(print.boldRedText( "ERROR: " & HTML2ANSI(err.message) ) );
		reader.printNewLine();
		if( structKeyExists( err, 'detail' ) ) {
			reader.printString(print.boldRedText( HTML2ANSI(err.detail) ) );
			reader.printNewLine();
		}
		if (structKeyExists( err, 'tagcontext' )) {
			var lines=arrayLen( err.tagcontext );
			if (lines != 0) {
				for(idx=1; idx<=lines; idx++) {
					tc = err.tagcontext[ idx ];
					if (len( tc.codeprinthtml )) {
						if( idx > 1 ) {
							reader.printString( print.boldCyanText( "called from " ) );
						}
						reader.printString(print.boldCyanText( "#tc.template#: line #tc.line##CR#" ));
						reader.printString( print.text( HTML2ANSI( tc.codeprinthtml ) ) );
					}
				}
			}
		}
		if( structKeyExists( err, 'stacktrace' ) ) {
			reader.printString( err.stacktrace );
		}
		reader.printNewLine();
	}

}
