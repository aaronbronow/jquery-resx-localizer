jquery-resx-localizer
=====================

An example app using jQuery to replace localized strings from RESX.

See a demo here: http://aaronbronow.com/jquery-resx-localizer

## How it works

Organize .resx files in a common directory like 'languages' in this example. The file naming convention comes from Visual Studio (Common.en-GB.resx). 

Use the data- attribute in your markup to identify elements to be updated automatically:

	// the inner text will be replaced
	<h1 class="title" data-localized-string="Common.Title">

In the JavaScript application, use the languages object to access the value of RESX nodes:

	// the value is read from Common.resx
	var label = app.languages.Common.FirstNavigationButton;

## Using data-* attributes

#### data-localized-string
	<h1 data-localized-string="Common.Title">Default Title</h1>

#### data-localized-placeholder
	<input type="text" data-localized-placeholder="Common.TypeUsernameHere" placeholder="Default placeholder..."/>

#### data-localized-title
	<img data-localized-title="Common.HeroImageTitle" title="Default title text"/>

#### data-localized-value
	<option data-localized-value="Common.FirstOption" value="Default first option text"/>