﻿package classes
{

	import classes.RoomClass;
	import classes.UIComponents.ButtonTooltips;
	import classes.UIComponents.LeftSideBar;
	import classes.UIComponents.RightSideBar;
	import classes.UIComponents.SideBarComponents.BigStatBlock;
	import classes.UIComponents.SquareButton;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.AntiAliasType;
	import flash.text.Font;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import fl.transitions.Tween;
	import fl.transitions.easing.Regular;
	import classes.UIComponents.MiniMap.MiniMap;
	import classes.GameData.TooltipManager;
	import classes.UIComponents.UIStyleSettings;

	import classes.StatBarSmall;
	import classes.StatBarBig;

	//Build the bottom drawer
	public class GUI extends MovieClip
	{
		var textBuffer:Array;
		
		//Used for temp buffer stuff
		var tempText:String;
		var tempAuthor:String;
		public var currentPCNotes:String;
		
		//Used for output()
		var outputBuffer:String;
		var outputBuffer2:String;
		var authorBuffer:Array;
		var textPage:int;

		//Lazy man state checking
		var showingPCAppearance:Boolean;

		//temporary nonsense variables.
		public var tempEvent:MouseEvent;
		var temp:int;

		var textInput:TextField;
		
		var buttonDrawer:BottomButtonDrawer;
		var buttons:Array;
		var buttonData:Array;
		var buttonPage:int;
		var buttonTooltip:ButtonTooltips;
		
		private var titsPurple:*;
		private var titsBlue:*;
		private var titsWhite:*;
		
		var buttonPagePrev:leftButton;
		var buttonPageNext:rightButton;
		var pagePrev:leftButton;
		var pageNext:rightButton;

		private var _rightSideBar:RightSideBar;
		private var _leftSideBar:LeftSideBar;

		var format1:TextFormat;
		var mainFont:Font3;
		var mainTextField:TextField;
		var mainTextField2:TextField;
		var upScrollButton:arrow;
		var downScrollButton:arrow;
		var scrollBar:Bar;
		var scrollBG:Bar;
		var mainMenuButtons:Array;
		var titleDisplay:titsLogo;
		var warningBackground:warningBG;
		var creditText:TextField;
		var warningText:TextField;
		var websiteDisplay:TextField;
		var titleFormat:TextFormat;
		public var myGlow:GlowFilter;

		private var npcStatSidebarItems:Array;
		
		private var miniMap:MiniMap;
		private var displayMinimap:Boolean;

		var titsClassPtr:*;
		var stagePtr:*;

		public function GUI(titsClassPtrArg:*, stagePtrArg:*)
		{
			// Pointer to the TiTS class
			// this is THE MOST HORRIBLE WORK-AROUND EVEN THEORETICALLY POSSIBLE.
			this.titsClassPtr = titsClassPtrArg;
			this.stagePtr = stagePtrArg;

			//Lazy man state checking
			this.showingPCAppearance = false;

			this.textBuffer = new Array("", "", "", "");
			
			//Used for temp buffer stuff
			this.tempText = "";
			this.tempAuthor = "";
			this.currentPCNotes = "No notes available.";
			
			//Used for output()
			this.outputBuffer = "";
			this.outputBuffer2 = "";
			this.authorBuffer = new Array("","","","");
			this.textPage = 4;

			this.buttonDrawer = new BottomButtonDrawer;
			this.titsClassPtr.addChild(buttonDrawer);
			this.buttonDrawer.x = 0;
			this.buttonDrawer.y = 800;

			//Build the buttons
			buttonTooltip = new ButtonTooltips();
			buttonTooltip.x = 5000;
			titsClassPtr.addChild(buttonTooltip);
			titsClassPtr.removeChild(buttonTooltip);
			
			this.buttons = new Array();
			this.buttonData = new Array();
			this.buttonPage = 1;
			this.initializeButtons();
			
			this.titsPurple = new ColorTransform();
			this.titsBlue = new ColorTransform();
			this.titsWhite = new ColorTransform();

			this.titsPurple.color = 0x84449B;
			this.titsBlue.color = 0x333E52;
			this.titsWhite.color = 0xFFFFFF;

			// Set up the various side-bars
			this.setupRightSidebar();
			this.setupLeftSidebar();
			this.ConfigureLeftBarTooltips();
			
			this.hidePCStats();

			// Setup the button page controls in the button tray
			this.buttonPageNext = new rightButton;
			this.buttonPageNext.name = "buttonPageNext";
			this.buttonPageNext.alpha = .3;
			this.buttonPageNext.x = 1100;
			this.buttonPageNext.y = 750;
			this.titsClassPtr.addChild(this.buttonPageNext);
			AttachTooltipListeners(this.buttonPageNext);

			this.buttonPagePrev = new leftButton;
			this.buttonPageNext.name = "buttonPagePrev";
			this.buttonPagePrev.alpha = .3;
			this.buttonPagePrev.x = 1000;
			this.buttonPagePrev.y = 750;
			this.titsClassPtr.addChild(this.buttonPagePrev);
			AttachTooltipListeners(this.buttonPagePrev);

			this.pageNext = new rightButton;
			this.pageNext.name = "bufferPageNext";
			this.pageNext.alpha = .3;
			this.pageNext.x = 110;
			this.pageNext.y = 750;
			this.titsClassPtr.addChild(this.pageNext);
			AttachTooltipListeners(this.pageNext);

			this.pagePrev = new leftButton;
			this.pagePrev.name = "bufferPagePrev";
			this.pagePrev.alpha = .3;
			this.pagePrev.x = 010;
			this.pagePrev.y = 750;
			this.titsClassPtr.addChild(this.pagePrev);
			AttachTooltipListeners(this.pagePrev);

			//Set up the main text field
			this.format1 = new TextFormat();
			this.format1.size = 18;
			this.format1.color = 0xFFFFFF;
			this.format1.tabStops = [35];
			format1.font = "Lato";
			
			this.mainTextField = new TextField();
			this.prepTextField(this.mainTextField);
			this.mainTextField.text = "Trails in Tainted Space booting up...\nLoading horsecocks...\nSpreading vaginas...\nLubricating anuses...\nPlacing traps...\n\n...my body is ready.";
			
			//Set up backup text field
			this.mainTextField2 = new TextField();
			this.prepTextField(this.mainTextField2);

			//Set up standard input box!
			this.textInput = new TextField();
			this.textInput.width = 250;
			this.textInput.height = 25;
			this.textInput.backgroundColor = 0xFFFFFF;
			this.textInput.border = true;
			this.textInput.borderColor = 0xFFFFFF;

			this.textInput.type = TextFieldType.INPUT;
			this.textInput.setTextFormat(format1);
			this.textInput.defaultTextFormat = format1;

			//SCROLLBAR!
			upScrollButton = new arrow();
			upScrollButton.x = mainTextField.x + mainTextField.width;
			upScrollButton.y = mainTextField.y
			downScrollButton = new arrow();
			downScrollButton.x = mainTextField.x + mainTextField.width + downScrollButton.width;
			downScrollButton.y = mainTextField.y + mainTextField.height;
			downScrollButton.rotation = 180;
			scrollBar = new Bar();
			scrollBar.x = mainTextField.x + mainTextField.width;
			scrollBar.y = mainTextField.y + upScrollButton.height;
			scrollBar.height = 50;
			scrollBG = new Bar();
			scrollBG.x = mainTextField.x + mainTextField.width;
			scrollBG.y = mainTextField.y + upScrollButton.height;
			scrollBG.height = mainTextField.height - upScrollButton.height - downScrollButton.height;
			scrollBG.transform.colorTransform = UIStyleSettings.gFadeOutColourTransform;
			this.titsClassPtr.addChild(scrollBG);
			this.titsClassPtr.addChild(scrollBar);
			this.titsClassPtr.addChild(upScrollButton);
			this.titsClassPtr.addChild(downScrollButton);
			
			//Since downscroll starts clickable...
			downScrollButton.buttonMode = true;

			clearMenu();

			//4. MAIN MENU STUFF
			this.mainMenuButtons = new Array();
			titleDisplay = new titsLogo();
			warningBackground = new warningBG();
			creditText = new TextField();
			warningText = new TextField();
			websiteDisplay = new TextField();
			titleFormat = new TextFormat();
			myGlow = new GlowFilter();
			myGlow.color = 0x84449B;
			myGlow.alpha = 1;
			myGlow.blurX = 10;
			myGlow.blurY = 10;
			myGlow.strength = 5;

			//Credit Text
			creditText.border = false;
			creditText.background = false;
			creditText.multiline = true;
			creditText.wordWrap = true;
			creditText.border = false;
			creditText.x = 210;
			creditText.y = 305;
			creditText.height = 77;
			creditText.width = 780;
			
			//Website Text
			websiteDisplay.border = false;
			websiteDisplay.htmlText = "http://www.trialsInTaintedSpace.com";
			websiteDisplay.background = false;
			websiteDisplay.multiline = true;
			websiteDisplay.wordWrap = true;
			websiteDisplay.border = false;
			websiteDisplay.x = 210;
			websiteDisplay.y = 475;
			websiteDisplay.height = 25;
			websiteDisplay.width = 780;
			
			//Warning Text
			warningText.border = false;

			warningText.background = false;
			warningText.multiline = true;
			warningText.wordWrap = true;
			warningText.border = false;
			warningText.x = 305;
			warningText.y = 390;
			warningText.height = 75;
			warningText.width = 655;
			
			//Set the formats
			titleFormat.size = 18;
			titleFormat.color = 0xFFFFFF;
			titleFormat.tabStops = [35];
			titleFormat.font = "Lato";
			titleFormat.align = TextFormatAlign.CENTER;

			creditText.setTextFormat(titleFormat);
			creditText.defaultTextFormat = titleFormat;
			warningText.setTextFormat(titleFormat);
			warningText.defaultTextFormat = titleFormat;
			websiteDisplay.setTextFormat(titleFormat);
			websiteDisplay.defaultTextFormat = titleFormat;

			titleDisplay.x = 368;
			titleDisplay.y = 142;

			//Add warning display
			warningBackground.x = 210;
			warningBackground.y = 380;
			this.titsClassPtr.addChild(titleDisplay);
			this.titsClassPtr.addChild(warningBackground);
			this.titsClassPtr.addChild(creditText);
			this.titsClassPtr.addChild(warningText);
			this.titsClassPtr.addChild(websiteDisplay);
			websiteDisplay.visible = false;
			creditText.visible = false;
			warningText.visible = false;
			titleDisplay.visible = false;
			websiteDisplay.visible = false;
			warningBackground.visible = false;

			initializeMainMenu();
		}
		
		private function setupRightSidebar():void
		{
			this._rightSideBar = new RightSideBar();
			this.titsClassPtr.addChild(_rightSideBar);
		}
		
		private function setupLeftSidebar():void
		{
			this._leftSideBar = new LeftSideBar(false);
			this.titsClassPtr.addChild(_leftSideBar);
			
			this._leftSideBar.generalInfoBlock.HideScene();
			
			this._leftSideBar.menuButton.Deactivate();
			this._leftSideBar.dataButton.Deactivate();
			this._leftSideBar.quickSaveButton.Deactivate();
			
			this._leftSideBar.statsButton.Deactivate();
			this._leftSideBar.perksButton.Deactivate();
			this._leftSideBar.levelUpButton.Deactivate();
			
			this._leftSideBar.appearanceButton.Deactivate();
			
			this.ConfigureLeftBarListeners();
		}
		
		/**
		 * Add the standard button listeners for the left hand menu
		 */
		private function ConfigureLeftBarListeners():void
		{
			this._leftSideBar.menuButton.addEventListener(MouseEvent.CLICK, titsClassPtr.mainMenuToggle);
			this._leftSideBar.appearanceButton.addEventListener(MouseEvent.CLICK, titsClassPtr.pcAppearance);
			this._leftSideBar.dataButton.addEventListener(MouseEvent.CLICK, titsClassPtr.dataManager.dataRouter);
		}
		
		private function ConfigureLeftBarTooltips():void 
		{
			AttachTooltipListeners(_leftSideBar.menuButton);
			AttachTooltipListeners(_leftSideBar.dataButton);
			AttachTooltipListeners(_leftSideBar.appearanceButton);
		}
		
		private function AttachTooltipListeners(displayObj:DisplayObject):void
		{
			displayObj.addEventListener(MouseEvent.ROLL_OVER, this.buttonTooltip.eventHandler);
			displayObj.addEventListener(MouseEvent.ROLL_OUT, this.buttonTooltip.eventHandler);
		}
		
		// Once this is all working, a lot of this should be refactored so that code external to GUI
		// doesn't directly access properties of UI elements.
		// f.ex rather than getting the players shield bar, then setting a value, engine code will
		// instead directly set a property on GUI for playerShields, which will then chain up through
		// whatever pile of objects it needs to, in order to actively display that value.
		// Once all code uses that kind of UI value setting, we can work on inverting the process, and
		// use data binding from UI element -> engine variable
		
		// Access methods to RSB items
		public function get playerShields():StatBarBig { return _rightSideBar.shieldBar; }
		public function get playerHP():StatBarBig { return _rightSideBar.hpBar; }
		public function get playerLust():StatBarBig { return _rightSideBar.lustBar; }
		public function get playerEnergy():StatBarBig { return _rightSideBar.energyBar; }
		
		public function get playerPhysique():StatBarSmall { return _rightSideBar.physiqueBar; }
		public function get playerReflexes():StatBarSmall { return _rightSideBar.reflexesBar; }
		public function get playerAim():StatBarSmall { return _rightSideBar.aimBar; }
		public function get playerIntelligence():StatBarSmall { return _rightSideBar.intelligenceBar; }
		public function get playerWillpower():StatBarSmall { return _rightSideBar.willpowerBar; }
		public function get playerLibido():StatBarSmall { return _rightSideBar.libidoBar; }
		
		public function get playerLevel():StatBarSmall { return _rightSideBar.levelBar; }
		public function get playerXP():StatBarSmall { return _rightSideBar.xpBar; }
		public function get playerCredits():StatBarSmall { return _rightSideBar.creditsBar; }
		public function set playerStatusEffects(statusEffects:Array):void { _rightSideBar.statusEffects.updateDisplay(statusEffects); }
		
		// Access to LSB items
		public function get roomText():String { return _leftSideBar.locationBlock.roomText.text; }
		public function get planetText():String { return _leftSideBar.locationBlock.planetText.text; }
		public function get systemText():String { return _leftSideBar.locationBlock.systemText.text; }
		
		public function set roomText(v:String):void { _leftSideBar.locationBlock.roomText.text = v; }
		public function set planetText(v:String):void { _leftSideBar.locationBlock.planetText.text = v; }
		public function set systemText(v:String):void { _leftSideBar.locationBlock.systemText.text = v; }
		
		public function get monsterShield():StatBarBig { return _leftSideBar.encounterShield; }
		public function get monsterHP():StatBarBig { return _leftSideBar.encounterHp; }
		public function get monsterLust():StatBarBig { return _leftSideBar.encounterLust; }
		public function get monsterEnergy():StatBarBig { return _leftSideBar.encounterEnergy; }
		public function get monsterLevel():StatBarSmall { return _leftSideBar.encounterLevel; }
		public function get monsterRace():StatBarSmall { return _leftSideBar.encounterRace; }
		public function get monsterSex():StatBarSmall { return _leftSideBar.encounterSex; }
		
		public function get time():String { return _leftSideBar.timeText.text; }
		public function set time(v:String):void { _leftSideBar.timeText.text = v; }
		public function get days():String { return _leftSideBar.daysText.text; }
		public function set days(v:String):void { _leftSideBar.daysText.text = v; }
		public function get sceneBy():String { return _leftSideBar.sceneBy.text; }
		public function set sceneBy(v:String):void { _leftSideBar.sceneBy.text = v; }
		
		public function get dataButton():SquareButton { return _leftSideBar.dataButton; }
		public function get mainMenuButton():SquareButton { return _leftSideBar.menuButton; }
		public function get appearanceButton():SquareButton { return _leftSideBar.appearanceButton; }
		
		// Useful functions I've pulled out of the rest of the code base
		public function setLocation(title:String, planet:String = "Error Planet", system:String = "Error System"):void
		{
			roomText = title;
			planetText = planet;
			systemText = system;
		}
		
		public function author(name:String):void
		{
			_leftSideBar.generalInfoBlock.sceneAuthor = name;
		}
		
		public function showSceneTag():void
		{
			_leftSideBar.generalInfoBlock.ShowScene();
		}
		
		//Build the main 15 buttons!
		public function initializeButtons():void 
		{
			trace("Initializing buttons")
			var temp = 0;
			//X and Y values for our buttons.
			var ex:int = 52;
			var why:int = 650;
			var texts:String = "Random#: ";
			while (temp < 60) {
				buttonData[temp] = new purpleButton;
				temp++;
			}
			temp = 0;
			while (temp < 15) {
				//Adjust for new rows
				if(temp % 5 == 0 && temp > 0) {
					ex -= 790;
					why += 50;
				}
				//Add on from previous button value.
				ex += 158;
				
				if (temp == 6 || temp == 10 || temp == 11 || temp == 12) {
					buttons[temp] = new purpleButton;
				}
				else {
					buttons[temp] = new blueButton;
				}
				this.titsClassPtr.addChild(buttons[temp]);
				
				buttons[temp].addEventListener(MouseEvent.ROLL_OVER, this.buttonTooltip.eventHandler);
				buttons[temp].addEventListener(MouseEvent.ROLL_OUT, this.buttonTooltip.eventHandler);
				
				buttons[temp].caption.htmlText = texts + String(Math.round(Math.random()*10));
				buttons[temp].x = ex;
				buttons[temp].y = why;
				buttons[temp].mouseChildren = false;
				//Add hotkey tags as appropriate.
				switch(temp) 
				{
					case 0:
							buttons[temp].hotkey.text = "1";
							break;
					case 1:
							buttons[temp].hotkey.text = "2";
							break;
					case 2:
							buttons[temp].hotkey.text = "3";
							break;
					case 3:
							buttons[temp].hotkey.text = "4";
							break;
					case 4:
							buttons[temp].hotkey.text = "5";
							break;
					case 5:
							buttons[temp].hotkey.text = "Q";
							break;
					case 6:
							buttons[temp].hotkey.text = "W";
							break;
					case 7:
							buttons[temp].hotkey.text = "E";
							break;
					case 8:
							buttons[temp].hotkey.text = "R";
							break;
					case 9:
							buttons[temp].hotkey.text = "T";
							break;
					case 10:
							buttons[temp].hotkey.text = "A";
							break;
					case 11:
							buttons[temp].hotkey.text = "S";
							break;
					case 12:
							buttons[temp].hotkey.text = "D";
							break;
					case 13:
							buttons[temp].hotkey.text = "F";
							break;
					case 14:
							buttons[temp].hotkey.text = "G";
							break;
				}
				temp++;
			}
		}

		public function hideTooltip():void
		{
			if (this.buttonTooltip.stage != null)
			{
				titsClassPtr.stage.removeChild(this.buttonTooltip);
			}
		}
		
		// This is more hacky shit that should go away when I rebuild the button tray. As it stands, the tooltips won't update for menu/page buttons
		// that get disabled via interaction (afaik)
		public function updateTooltip(displayObj:DisplayObject):void
		{
			if (this.buttonTooltip.stage != null)
			{
				var btn:*;
				
				if (displayObj is blueButton) btn = (displayObj as blueButton);
				else if (displayObj is purpleButton) btn = (displayObj as purpleButton);
				
				if (btn.caption.text.length > 0)
				{
					this.buttonTooltip.DisplayForObject(displayObj);
				}
				else
				{
					this.hideTooltip();
				}
			}
		}
		
		public function getGuiPlayerNameText():String
		{
			return this._rightSideBar.nameText.text;
		}
		
		public function setGuiPlayerNameText(inName:String):void
		{
			this._rightSideBar.nameText.text = inName;
		}

		//1. BUTTON STUFF
		public function clearMenu():void {
			for(var x:int = 0; x < buttons.length ;x++) {
				buttons[x].func = undefined;
				buttons[x].arg = undefined;
				buttons[x].alpha = .3;
				buttons[x].caption.text = "";
				buttons[x].buttonMode = false;
				while(buttons[x].hasEventListener(MouseEvent.CLICK)) buttons[x].removeEventListener(MouseEvent.CLICK,titsClassPtr.buttonClick);
			}
			for(x = 0; x < buttonData.length; x++) {
				buttonData[x].func = undefined;
				buttonData[x].arg = undefined;
				buttonData[x].caption.text = "";
			}
			menuPageChecker();
		}
		
		//Used for ghost menus in main menu and options.
		public function clearGhostMenu():void {
			for(var x:int = 0; x < buttons.length ;x++) {
				buttons[x].func = undefined;
				buttons[x].arg = undefined;
				buttons[x].alpha = .3;
				buttons[x].caption.text = "";
				buttons[x].buttonMode = false;
				while(buttons[x].hasEventListener(MouseEvent.CLICK)) buttons[x].removeEventListener(MouseEvent.CLICK,titsClassPtr.buttonClick);
			}
			//menuPageChecker();
		}

		public function forwardPageButtons(e:MouseEvent):void {
			pageButtons();
		}
		
		public function backPageButtons(e:MouseEvent):void {
			pageButtons(false);
		}

		public function menuPageChecker():void {
			var lastButton:int = 0;
			for(var x:int = 0; x < buttonData.length; x++) {
				if(buttonData[x].caption.text != "") {
					lastButton = x;
				}
			}
			//If you can go right still.
			if((lastButton + 1)/15 > buttonPage) {
				if(buttonPageNext.alpha != 1) {
					buttonPageNext.addEventListener(MouseEvent.CLICK,forwardPageButtons);
					buttonPageNext.alpha = 1;
					buttonPageNext.buttonMode = true;
				}
			}
			//If you can't go right but the button aint turned off.
			else if(buttonPageNext.alpha != .3) {
				buttonPageNext.removeEventListener(MouseEvent.CLICK,forwardPageButtons);
				buttonPageNext.alpha = .3;
				buttonPageNext.buttonMode = false;
			}
			//Left hooo!
			if(buttonPage != 1) {
				if(buttonPagePrev.alpha != 1) {
					buttonPagePrev.addEventListener(MouseEvent.CLICK,backPageButtons);
					buttonPagePrev.alpha = 1;
					buttonPagePrev.buttonMode = true;
				}
			}
			//If you can't go right but the button aint turned off.
			else if(buttonPagePrev.alpha != .3) {
				buttonPagePrev.removeEventListener(MouseEvent.CLICK,backPageButtons);
				buttonPagePrev.alpha = .3;
				buttonPagePrev.buttonMode = false;
			}
		}

		public function pageButtons(forward:Boolean = true):void {
			if(forward) buttonPage++;
			else buttonPage--;
			if(buttonPage < 1) buttonPage = 1;
			else if(buttonPage > 4) buttonPage = 4;
			var diff:int = (buttonPage-1) * 15;
			for(var x:int = 0; x < buttons.length ;x++) {
				buttons[x].func = buttonData[x+diff].func;
				//Inactive button gets put transparent and listeners removed.
				if(buttonData[x+diff].caption.text == "" || buttonData[x+diff].func == undefined) {
					buttons[x].alpha = .3;
					buttons[x].caption.text = buttonData[x+diff].caption.text;
					while(buttons[x].hasEventListener(MouseEvent.CLICK)) buttons[x].removeEventListener(MouseEvent.CLICK,titsClassPtr.buttonClick);
					buttons[x].buttonMode = false;
				}
				else {
					buttons[x].arg = buttonData[x+diff].arg;
					buttons[x].alpha = 1;
					buttons[x].buttonMode = true;
					buttons[x].caption.text = buttonData[x+diff].caption.text;
					buttons[x].addEventListener(MouseEvent.CLICK,titsClassPtr.buttonClick);
				}
			}
			//Check back/next buttons
			menuPageChecker();
		}
			
		public var mainTextStylesheet:StyleSheet = new StyleSheet();
		
		public function prepTextField(arg:TextField):void 
		{
			// Using this stylesheet, we can apply the _family_ of font faces to format the textfield.
			// That means <b> and <i> text will /actually use/ the lato font faces; they actually weren't using the right glyphs before!
			var defaultCSSTag = { fontFamily:"Lato", fontSize:18, color:"#FFFFFF", marginRight:5 };
			
			// This is where everything comes a little unstuck. I don't THINK you can apply a global style to everything.
			// The current bullshit method wraps a class'd <span> around all output. This does, however, come at a price, possibly; I think I know what causes the sticky formatting. If an incomplete <b> or <i> tag is ever parsed by the htmlText property of the text field, the formatting will get "stuck" and I'm trying to work out a good way of catching it when it happens, or "clearing" the sticky format.

			mainTextStylesheet.setStyle(".words", defaultCSSTag);
			
			arg.border = false;
			arg.text = "Placeholder";
			arg.background = false;
			arg.multiline = true;
			arg.wordWrap = true;
			arg.border = false;
			arg.embedFonts = true; // Forces the field to use embedded fonts
			arg.antiAliasType = AntiAliasType.ADVANCED; // PRETTY NICENESS
			arg.x = 211;
			arg.y = 5;
			arg.height = 630;
			arg.width = 760;
			arg.styleSheet = mainTextStylesheet;
			this.titsClassPtr.addChild(arg);
			arg.visible = false;
		}

		public function addButton(slot:int,cap:String = "",func = undefined,arg = undefined):void {
			if(slot <= 14) {
				buttons[slot].alpha = 1;
				buttons[slot].caption.text = cap;
				buttons[slot].addEventListener(MouseEvent.CLICK,titsClassPtr.buttonClick);
				buttons[slot].func = func;
			
				buttons[slot].arg = arg;
			
				buttons[slot].buttonMode = true;
			}	
			buttonData[slot].func = func;
			buttonData[slot].arg = arg;
			buttonData[slot].caption.text = cap;
			menuPageChecker();
		}
		
		public function hasButton(slot:int):Boolean {
			if(buttons[slot].alpha > 0) return true;
			return false;
		}
		
		//Returns the position of the last used buttonData spot.
		function lastButton():int 
		{
			for(var x:int = buttonData.length; x >= 0; x--) {
				if(buttonData[x].caption.text != "") break;
			}
			if(buttonData[x].caption.text == "" && x == 0) x = -1;
			return x;
		}
		
		public function addDisabledButton(slot:int,cap:String = ""):void {
			if(slot <= 14) {
				buttons[slot].alpha = .3;
				buttons[slot].caption.text = cap;
				//buttons[slot].addEventListener(MouseEvent.CLICK,titsClassPtr.buttonClick);
				buttons[slot].func = undefined;
				buttons[slot].arg = undefined;
				buttons[slot].buttonMode = false;
			}	
			buttonData[slot].func = undefined;
			buttonData[slot].arg = undefined;
			buttonData[slot].caption.text = cap;
			menuPageChecker();
		}
		
		//Ghost button - used for menu buttons that overlay the normal buttons. 
		public function addGhostButton(slot:int, cap:String = "", func = undefined, arg = undefined):void 
		{
			if(slot > 14) return;
			buttons[slot].alpha = 1;
			buttons[slot].caption.text = cap;
			buttons[slot].addEventListener(MouseEvent.CLICK,titsClassPtr.buttonClick);
			buttons[slot].func = func;
			buttons[slot].arg = arg;
			buttons[slot].buttonMode = true;
		}
		
		public function addMainMenuButton(slot:int, cap:String = "", func = undefined, arg = undefined):void 
		{
			if(slot <= this.mainMenuButtons.length) {
				this.mainMenuButtons[slot].alpha = 1;
				this.mainMenuButtons[slot].caption.text = cap;
				this.mainMenuButtons[slot].addEventListener(MouseEvent.CLICK,titsClassPtr.buttonClick);
				this.mainMenuButtons[slot].func = func;
			
				this.mainMenuButtons[slot].arg = arg;
			
				this.mainMenuButtons[slot].buttonMode = true;
				this.mainMenuButtons[slot].visible = true;
			}	
			menuPageChecker();
		}

		public function pushToBuffer():void 
		{
			if(tempText != "") {
				textBuffer[textBuffer.length] = tempText;
				authorBuffer[authorBuffer.length] = tempAuthor;
				tempText = "";
				tempAuthor = "";
			}
			else {
				textBuffer[textBuffer.length] = mainTextField.htmlText;
				authorBuffer[authorBuffer.length] = sceneBy;
			}
			if(textBuffer.length > 4) {
				textBuffer.splice(0,1);
				authorBuffer.splice(0,1);
			}
		}

		public function forwardBuffer(e:MouseEvent):void 
		{
			if(textPage < 4) {
				textPage++;
			}
			else return;
			mainTextField.text = "";
			updateScroll(e);
			trace("TextPage: " + textPage);
			if(textPage == 4) {
				mainTextField.htmlText = tempText;
				sceneBy = tempAuthor;
			}
			else {
				mainTextField.htmlText = textBuffer[textPage];
				sceneBy = authorBuffer[textPage];
			}
			updateScroll(e);
			titsClassPtr.bufferButtonUpdater();
		}
		
		public function backBuffer(e:MouseEvent):void 
		{
			if(textPage == 4) {
				tempText = mainTextField.htmlText;
				tempAuthor = sceneBy;
			}
			if(textPage > 0) {
				textPage--;
			}
			else return;
			mainTextField.text = "";
			updateScroll(e);
			trace("TextPage: " + textPage);
			mainTextField.htmlText = textBuffer[textPage];
			sceneBy = authorBuffer[textPage];
			updateScroll(e);
			titsClassPtr.bufferButtonUpdater();
		}

		public function displayInput():void 
		{
			if(!this.stagePtr.contains(textInput)) this.titsClassPtr.addChild(textInput);
			textInput.text = "";
			textInput.visible = true;
			textInput.width = 160;
			textInput.x = mainTextField.x + 2;
			textInput.y = mainTextField.y + 8 + mainTextField.textHeight;
			textInput.visible = true;
			menuButtonsOff();
			appearanceOff();
			for (var x:int = 0; x < 15; x++) {
				buttons[x].hotkey.text = "-";
			}
			this.stagePtr.focus = textInput;
			textInput.text = "";
			textInput.maxChars = 0;
		}
		
		public function removeInput():void 
		{
			this.titsClassPtr.removeChild(textInput);
			menuButtonsOn();

			buttons[0].hotkey.text = "1";
			buttons[1].hotkey.text = "2";
			buttons[2].hotkey.text = "3";
			buttons[3].hotkey.text = "4";
			buttons[4].hotkey.text = "5";
			buttons[5].hotkey.text = "Q";
			buttons[6].hotkey.text = "W";
			buttons[7].hotkey.text = "E";
			buttons[8].hotkey.text = "R";
			buttons[9].hotkey.text = "T";
			buttons[10].hotkey.text = "A";
			buttons[11].hotkey.text = "S";
			buttons[12].hotkey.text = "D";
			buttons[13].hotkey.text = "F";
			buttons[14].hotkey.text = "G";
		}

		//Used to adjust position of scroll bar!
		public function updateScroll(e:MouseEvent):void 
		{
			var target = mainTextField;
			if(!target.visible) target = mainTextField2;
			//Set the size of the bar!
			//Number of lines on screen
			var pageSize:int = target.bottomScrollV - target.scrollV + 1;
				//trace("Bottom Scroll V: " + target.bottomScrollV);
				//trace("Page Size: " + pageSize);
			//Fix pagesize for super tiny
			if(pageSize <= 0) pageSize = 1;
			//Number of pages
			var pages:Number = target.numLines / pageSize;
				//trace("Pages: " + pages);
			scrollBar.height = pageSize / target.numLines * (target.height - upScrollButton.height - downScrollButton.height);
			if(scrollBar.height < scrollBG.height) scrollBar.buttonMode = true;
			else scrollBar.buttonMode = false;
			
			//Set the position of the bar
			//the size of the scroll field
			var field:Number = target.height - upScrollButton.height - scrollBar.height - downScrollButton.height;
				//trace("Field: " + field);
			var progress:Number = 0;
			var min = target.scrollV;
			var max = target.maxScrollV;
				//trace("Min: " + min);
			//Don't divide by zero - cheese it to work.
			if(max == 1) {
				max = 2;
				min = 2;
			}
			progress = (min-1) / (max-1);
				//trace("Progress: " + progress);
				//trace("Progress x Field: " + progress * field);
			scrollBar.y = target.y + progress * field + upScrollButton.height;
			titsClassPtr.scrollChecker();
		}

		//4. MIAN MENU STUFF
		public function mainMenuButtonOn():void 
		{
			_leftSideBar.menuButton.Activate();
		}
		
		public function mainMenuButtonOff():void 
		{
			_leftSideBar.menuButton.Deactivate();
		}
		
		public function appearanceOn():void 
		{
			_leftSideBar.appearanceButton.Activate();
		}
		
		public function appearanceOff():void 
		{
			_leftSideBar.appearanceButton.Deactivate();
		}
		
		public function dataOn():void 
		{
			_leftSideBar.dataButton.Activate();
		}

		public function hideNormalDisplayShit():void 
		{
			//Hide all current buttons
			for(var x:int = 0; x < buttons.length ;x++) {
				buttons[x].func = undefined;
				buttons[x].alpha = .3;
				buttons[x].caption.text = "";
				while(buttons[x].hasEventListener(MouseEvent.CLICK)) buttons[x].removeEventListener(MouseEvent.CLICK,titsClassPtr.buttonClick);
				buttons[x].buttonMode = false;
			}
			//Hide scrollbar & main text!
			upScrollButton.visible = false;
			downScrollButton.visible = false;
			scrollBar.visible = false;
			scrollBG.visible = false;
			mainTextField.visible = false;
			mainTextField2.visible = false;
			//Page buttons invisible!
			buttonPageNext.visible = false;
			buttonPagePrev.visible = false;
			pageNext.visible = false;
			pagePrev.visible = false;
		}

		public function menuButtonsOn():void 
		{
			//trace("this.stagePtr = ", this.stagePtr);
			if (!titsClassPtr.pc.hasStatusEffect("In Creation") && titsClassPtr.pc.short != "uncreated") 
			{
				appearanceOn();
			}
			if (!this.stagePtr.contains(this.textInput)) 
			{
				mainMenuButtonOn();
				this.dataOn();
			}
		}
		
		public function menuButtonsOff():void 
		{
			appearanceOff();
			mainMenuButtonOff();
		}
		
		public function hideMenus():void 
		{
			hideMainMenu();
			hideAppearance();
			hideData();
		}

		public function hideData():void 
		{
			_leftSideBar.dataButton.DeGlow();
		}

		public function hideAppearance():void 
		{
			//Not showing appearance anymore!
			showingPCAppearance = false;
			
			//Hide scrollbar & main text!
			upScrollButton.visible = true;
			downScrollButton.visible = true;
			scrollBar.visible = true;
			scrollBG.visible = true;
			mainTextField.visible = true;
			mainTextField2.visible = false;
			
			//Show menu shits
			creditText.visible = false;
			warningText.visible = false;
			titleDisplay.visible = false;
			warningBackground.visible = false;
			websiteDisplay.visible = false;
			
			//Turn off main menu buttons
			for (var x:int = 0; x < this.mainMenuButtons.length ; x++) 
			{
				this.mainMenuButtons[x].func = undefined;
				this.mainMenuButtons[x].alpha = .3;
				this.mainMenuButtons[x].caption.text = "";
				while(this.mainMenuButtons[x].hasEventListener(MouseEvent.CLICK)) this.mainMenuButtons[x].removeEventListener(MouseEvent.CLICK,titsClassPtr.buttonClick);
				this.mainMenuButtons[x].buttonMode = false;
				this.mainMenuButtons[x].visible = false;
			}
			
			//Turn buttons back on
			var diff:int = (buttonPage-1) * 15;
			for(x = 0; x < buttons.length ;x++) {
				buttons[x].func = buttonData[x+diff].func;
				//Inactive button gets put transparent and listeners removed.
				if(buttonData[x+diff].func != undefined) {
					buttons[x].arg = buttonData[x+diff].arg;
					buttons[x].alpha = 1;
					buttons[x].buttonMode = true;
					buttons[x].caption.text = buttonData[x+diff].caption.text;
					buttons[x].addEventListener(MouseEvent.CLICK,titsClassPtr.buttonClick);
				}
				else {
					buttons[x].arg = undefined;
					buttons[x].alpha = .3;
					buttons[x].buttonMode = false;
					buttons[x].caption.text = "";
					buttons[x].removeEventListener(MouseEvent.CLICK,titsClassPtr.buttonClick);
				}
			}
			//Page buttons visible and updated!
			buttonPageNext.visible = true;
			buttonPagePrev.visible = true;
			menuPageChecker();
			pageNext.visible = true;
			pagePrev.visible = true;
			menuButtonsOn();
			_leftSideBar.appearanceButton.DeGlow();
			titsClassPtr.bufferButtonUpdater();
		}

		public function hideMainMenu():void 
		{
			//Hide scrollbar & main text!
			upScrollButton.visible = true;
			downScrollButton.visible = true;
			scrollBar.visible = true;
			scrollBG.visible = true;
			mainTextField.visible = true;
			mainTextField2.visible = false;
			
			//Show menu shits
			creditText.visible = false;
			warningText.visible = false;
			titleDisplay.visible = false;
			warningBackground.visible = false;
			websiteDisplay.visible = false;
			
			//Turn off main menu buttons
			for(var x:int = 0; x < this.mainMenuButtons.length ;x++) {
				this.mainMenuButtons[x].func = undefined;
				this.mainMenuButtons[x].alpha = .3;
				this.mainMenuButtons[x].caption.text = "";
				while(this.mainMenuButtons[x].hasEventListener(MouseEvent.CLICK)) this.mainMenuButtons[x].removeEventListener(MouseEvent.CLICK,titsClassPtr.buttonClick);
				this.mainMenuButtons[x].buttonMode = false;
				this.mainMenuButtons[x].visible = false;
			}
			
			//Turn buttons back on
			var diff:int = (buttonPage-1) * 15;
			for(x = 0; x < buttons.length ;x++) {
				buttons[x].func = buttonData[x+diff].func;
				//Inactive button gets put transparent and listeners removed.
				if(buttonData[x+diff].func != undefined) {
					buttons[x].arg = buttonData[x+diff].arg;
					buttons[x].alpha = 1;
					buttons[x].buttonMode = true;
					buttons[x].caption.text = buttonData[x+diff].caption.text;
					buttons[x].addEventListener(MouseEvent.CLICK,titsClassPtr.buttonClick);
				}
			}
			//Page buttons visible and updated!
			buttonPageNext.visible = true;
			buttonPagePrev.visible = true;
			menuPageChecker();
			pageNext.visible = true;
			pagePrev.visible = true;
			menuButtonsOn();
			_leftSideBar.menuButton.DeGlow();
			titsClassPtr.bufferButtonUpdater();
		}

		public function initializeMainMenu():void 
		{
			//Initialize main menu buttons
			var currButtonX:int = 210;
			var currButtonY:int = 518;
			for(x = 0; x < 6; x++) {
				if(x <= 2) this.mainMenuButtons[x] = new blueMainButton;
				else this.mainMenuButtons[x] = new blueMainButtonBig;
				//Adjust for new rows
				if(x == 3) {
					currButtonX -= 474;
					currButtonY += 50;
				}
				//Add on from previous button value.
				currButtonX += 158;
				this.titsClassPtr.addChild(this.mainMenuButtons[x]);
				this.mainMenuButtons[x].caption.htmlText = String(x);
				
				this.mainMenuButtons[x].x = currButtonX;
				
				this.mainMenuButtons[x].y = currButtonY;
				
				this.mainMenuButtons[x].mouseChildren = false;
				this.mainMenuButtons[x].visible = false;
			}
		}
		
		public function leftBarClear():void 
		{
			_leftSideBar.generalInfoBlock.HideScene();
			_leftSideBar.roomText.visible = false;
			_leftSideBar.planetText.visible = false;
			_leftSideBar.systemText.visible = false;
			_leftSideBar.generalInfoBlock.HideTime();
			_leftSideBar.quickSaveButton.visible = false;
			_leftSideBar.dataButton.visible = false;
			_leftSideBar.statsButton.visible = false;
			_leftSideBar.perksButton.visible = false;
			_leftSideBar.levelUpButton.visible = false;
		}
		
		public function hideTime():void 
		{
			_leftSideBar.generalInfoBlock.HideTime();
		}
		
		public function showTime():void 
		{
			_leftSideBar.generalInfoBlock.ShowTime();
		}
		
		public function hidePCStats():void 
		{
			this._rightSideBar.hideItems();
		}
		
		public function showPCStats():void 
		{
			this._rightSideBar.showItems();
		}
		
		public function resetPCStats():void
		{
			this._rightSideBar.resetItems();
		}
		
		public function showNPCStats():void 
		{
			_leftSideBar.ShowStats();
		}
		
		public function resetNPCStats():void
		{
			_leftSideBar.encounterBlock.resetItems();
		}
		
		public function showMinimap():void
		{
			_leftSideBar.ShowMiniMap();
		}
		
		public function hideNPCStats():void 
		{
			_leftSideBar.HideStats();
		}
		
		public function hideMinimap():void
		{
			_leftSideBar.HideMiniMap();
		}
		
		public function deglow():void 
		{
			_rightSideBar.removeGlows();
			_leftSideBar.encounterBlock.removeGlows();
		}	

		public function showBust(... args):void 
		{
			var argS:String = "";
			for (var i:int = 0; i < args.length; i++)
			{
				if (i > 0) argS += ", ";
				argS += args[i];
			}
			trace("showBust called with args: [" + argS + "]");
			_leftSideBar.locationBlock.showBust(args);			
		}
		
		public function hideBust():void
		{
			trace("hideBust called");
			_leftSideBar.locationBlock.hideBust();
		}

		//2. DISPLAY STUFF
		//EXAMPLE: setupStatBar(monsterSex,"SEX","Genderless");
		function setupStatBar(arg:MovieClip, title:String = "", value = undefined, max = undefined):void 
		{
			if(title != "" && title is String) arg.masks.labels.text = title;
			if(max is Number && value is Number) {
				arg.bar.width = (value / max) * 180;
				arg.background.x = -1 * (1 - value / max) * 180;
			}
			if(max == undefined) {
				arg.bar.visible = false;
				arg.background.x = -180;
			}
			if(value != undefined) arg.values.text = String(value);
		}
		
		// Set the current map data
		public function setMapData(data:*):void
		{
			this._leftSideBar.miniMap.setMapData(data);
			_leftSideBar.ShowMiniMap();
		}

	}
}