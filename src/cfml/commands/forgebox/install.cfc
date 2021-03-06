/**
 * This command will download and install an entry from ForgeBox into your application.  You must use the 
 *  exact slug for the item you want.  If the item being installed has a box.json descriptor, it's "directory"
 *  property will be used as the install location. In the absence of that setting, the current CommandBox working
 *  directory will be used.  Override the installation location by passing the "directory" parameter.
 *  
 *  forgebox install feeds
 *  
 **/
component persistent="false" extends="commandbox.system.BaseCommand" aliases="install" excludeFromHelp=false {
	
	// Create our ForgeBox helper
	variables.forgebox = new commandbox.system.util.ForgeBox();
	
	/**
	* @slug.hint Slug of the ForgeBox entry to install
	* @directory.hint The directory to install in
	**/
	function run( 
				required slug,
				directory=shell.pwd() ) {
								
		directory = fileSystemUtil.resolveDirectory( directory );
						
		// Validate directory
		if( !directoryExists( directory ) ) {
			return error( 'The directory [#directory#] doesn''t exist.' );			
		}
		
		try {
			
			// We might have gotten this above
			var entryData = forgebox.getEntry( slug );
			
			// entrylink,createdate,lname,isactive,installinstructions,typename,version,hits,coldboxversion,sourceurl,slug,homeurl,typeslug,
			// downloads,entryid,fname,changelog,updatedate,downloadurl,title,entryrating,summary,username,description,email
							
			if( !val( entryData.isActive ) ) {
				error( 'The ForgeBox entry [#entryData.title#] is inactive.' );
			}
			
			if( !len( entryData.downloadurl ) ) {
				error( 'No download URL provided.  Manual install only.' );
			}
			
			// TODO: create ArtifactsService, etc. to handle this
			// Also check box.json for "directory".
			// 1) Use directory param first
			// 2) Fall back on box.json directory
			// 3) Fall back on shell.pwd() 
			results = forgebox.install( entryData.downloadurl, directory );
			
			var log = results.logInfo;
			log = ANSIUtil.HTML2ANSI( log );
		
			print.line();
			print.boldLine( 'Install log...' );
			print.line();
			 
			// TODO: Find a way to print and flush these messages while the install actually happens.
			// A progress bar if possible for downloads would be very cool
			print.line( log );
			
			if( results.error ) {
				print.boldRedLine( 'Error Installing!' );
			} else {
				print.boldGreenLine( 'Success!' );
			}
			
			
		} catch( forgebox var e ) {
			// This can include "expected" errors such as "slug not found"
			return error( '#e.message##CR##e.detail#' );
		}
		
	}

} 