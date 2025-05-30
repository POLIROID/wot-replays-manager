﻿package me.poliroid.rmanager
{	
	import flash.text.TextField;
	import flash.display.InteractiveObject;
	
	import net.wg.gui.components.advanced.ViewStack;
	import net.wg.gui.components.windows.WindowEvent;
	import net.wg.infrastructure.base.AbstractWindowView;
	import net.wg.infrastructure.constants.WindowViewInvalidationType;
	import net.wg.infrastructure.interfaces.IWindow;
	
	import me.poliroid.rmanager.components.Paginator;
	
	import me.poliroid.rmanager.events.ReplayActionEvent;
	import me.poliroid.rmanager.events.PagingEvent;
	import me.poliroid.rmanager.events.SortingEvent;
	import me.poliroid.rmanager.events.FilterEvent;
	
	import me.poliroid.rmanager.lang.STRINGS;
	import me.poliroid.rmanager.ui.ReplaysViewUI;
	import me.poliroid.rmanager.utils.Helpers;
	import me.poliroid.rmanager.utils.Utils;
	
	public class ReplaysManagerWindow extends AbstractWindowView
	{
		
		public var view:ViewStack = null;
		public var updateReplaysList:Function = null;
		public var onReplayAction:Function = null;
		
		private var settingsObject:Object = {
			filters: {
				favorite: -1, 
				battleType: -1, 
				mapName: "",
				isWinner: -100,
				tankInfo: {
					vehicleNation: -1, 
					vehicleLevel: -1, 
					vehicleType: ""
				}, 
				dateTime: "all", 
				originalXP: -1
			}, 
			sorting: {
				key: "timestamp", 
				reverse: true
			}, 
			paging: {
				pageSize: Paginator.PAGE_SIZE, 
				page: 1
			}
		};
		
		public function ReplaysManagerWindow()
		{
			super();
		}
		
		override public function setWindow(param1:IWindow) : void
		{
			super.setWindow(param1);
			if(window)
			{
				window.title = STRINGS.l10n('ui.window.title');
			}
		}
		
		override protected function configUI() : void
		{
			super.configUI();
			window.addEventListener(WindowEvent.SCALE_Y_CHANGED, this.onWindowScaleYChangedHandler);
		}
		
		override protected function onPopulate():void
		{
			super.onPopulate();
			try
			{
				if(window)
				{
					window.title = STRINGS.l10n('ui.window.title');
				}
				this.view.addEventListener(PagingEvent.PAGE_CHANGED, this.handlePageChanged);
				this.view.addEventListener(SortingEvent.SORT_KEY_CHANGED, this.handleSortingChanged);
				this.view.addEventListener(FilterEvent.FILTERS_CHANGED, this.handleFiltersChanged);
				this.view.addEventListener(ReplayActionEvent.REPLAY_ACTION, this.handleReplayAction);
				
				Helpers.ConfigureViewStack(this.view);
				this.view.show(Helpers.REPLAYS, Helpers.REPLAYS);
				
			}
			catch (err:Error)
			{
				DebugUtils.LOG_ERROR("ReplaysManagerWindow::onPopulate: " + err.getStackTrace());
			}
		
		}
		
		override protected function onDispose():void
		{
			this.view.removeEventListener(PagingEvent.PAGE_CHANGED, this.handlePageChanged);
			this.view.removeEventListener(SortingEvent.SORT_KEY_CHANGED, this.handleSortingChanged);
			this.view.removeEventListener(FilterEvent.FILTERS_CHANGED, this.handleFiltersChanged);
			this.view.removeEventListener(ReplayActionEvent.REPLAY_ACTION, this.handleReplayAction);
			
			this.view.dispose();
			this.view = null;
			
			super.onDispose();
		}
		
		override protected function draw() : void
		{
			super.draw();
			if(geometry && window && isInvalid(WindowViewInvalidationType.POSITION_INVALID))
			{
				window.x = App.appWidth - window.getBackground().width >> 1;
				window.y = App.appHeight - window.getBackground().height >> 1;
			}
		}
		
		private function handleReplayAction(event:ReplayActionEvent):void
		{
			this.onReplayAction(event.actionType, event.replayName);
		}
		
		private function handlePageChanged(event:PagingEvent):void
		{
			this.settingsObject["paging"]["page"] = event.currentPage;
			this.updateReplaysList(App.utils.JSON.encode(this.settingsObject), true);
		}
		
		private function handleSortingChanged(event:SortingEvent):void
		{
			this.settingsObject["sorting"]["key"] = event.sortKey;
			this.settingsObject["sorting"]["reverse"] = !event.ascending;
			this.updateReplaysList(App.utils.JSON.encode(this.settingsObject));
		}
		
		private function handleFiltersChanged(event:FilterEvent):void
		{
			this.settingsObject["filters"] = Utils.mergeObjects(this.settingsObject["filters"], event.data);
			this.updateReplaysList(App.utils.JSON.encode(this.settingsObject));
		}
		
		public function as_setAPIStatus(status:Boolean):void
		{
			Helpers.apiStatus = status;
		}
		
		public function as_initFilters(maps:Array, battleTypes:Array):void
		{
			try
			{
				var currentView:ReplaysViewUI = ReplaysViewUI(this.view.currentView);
				currentView.setFiltersData(maps, battleTypes);
			}
			catch (err:Error)
			{
				DebugUtils.LOG_ERROR("ReplaysManagerWindow::as_initFilters: " + err.getStackTrace());
			}
		}
		
		public function as_setReplaysData(data:Array, itemsCount:Number):void
		{
			try
			{
				DebugUtils.LOG_DEBUG("as_setReplaysData", data.length, itemsCount);
				var currentView:ReplaysViewUI = ReplaysViewUI(this.view.currentView);
				currentView.update({id: Helpers.REPLAYS, data: data, itemsCount: itemsCount});
			}
			catch (err:Error)
			{
				DebugUtils.LOG_ERROR("ReplaysManagerWindow::as_setReplaysData: " + err.getStackTrace());
			}
		}
		
		public function as_setLangData(data:Object):void
		{
			try
			{
				DebugUtils.LOG_DEBUG("as_setLangData");
				STRINGS.setData(data);
			}
			catch (err:Error)
			{
				DebugUtils.LOG_ERROR("ReplaysManagerWindow::as_setLangData: " + err.getStackTrace());
			}
		}
		
		public function as_updateWaiting(_label:String):void
		{
			try
			{
				if (waiting) waiting.setMessage(_label);
			}
			catch (err:Error)
			{
				DebugUtils.LOG_ERROR("ReplaysManagerWindow::as_updateWaiting: " + err.getStackTrace());
			}
		}
		
		private function onWindowScaleYChangedHandler(param1:WindowEvent) : void
		{
			invalidate(WindowViewInvalidationType.POSITION_INVALID);
		}
	}

}
