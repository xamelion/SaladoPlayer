﻿/*
Copyright 2010 Marek Standio.

This file is part of SaladoPlayer.

SaladoPlayer is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published 
by the Free Software Foundation, either version 3 of the License, 
or (at your option) any later version.

SaladoPlayer is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty 
of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with SaladoPlayer.  If not, see <http://www.gnu.org/licenses/>.
*/
package com.panozona.modules.imagemap.controller {
	
	
	import com.panozona.modules.imagemap.model.WaypointData;
	import com.panozona.modules.imagemap.view.WaypointView;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.display.Loader;
	import flash.net.URLRequest;
	
	import com.panozona.player.module.Module;
	import com.panozona.modules.imagemap.view.MapView;
	import com.panozona.modules.imagemap.events.MapEvent;
	
	import com.panozona.modules.imagemap.model.structure.Map;
	import com.panozona.modules.imagemap.model.structure.Waypoint;	
	
	/**
	 * @author mstandio
	 */
	public class MapController {
		
		private var _mapView:MapView; 
		private var _module:Module;
		
		private var waypointControlers:Array;
		
		private var mapImageLoader:Loader;
		
		public function MapController(mapView:MapView, module:Module){
			_mapView = mapView;
			_module = module;
			
			waypointControlers = new Array();
			
			_mapView.mapData.addEventListener(MapEvent.CHANGED_CURRENT_MAP_ID, handleCurrentMapIdChange, false, 0, true);
		}
		
		public function loadFirstMap():void {
			// TODO: check firstMap and if not load firs tmap in line, like below:
			_mapView.mapData.currentMapId = (_mapView.mapData.maps.getChildrenOfGivenClass(Map)[0]).id;
		}
		
		private function handleCurrentMapIdChange(e:Event):void {
			if (mapImageLoader == null) {
				mapImageLoader = new Loader();
				mapImageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, mapImageLost, false, 0, true);
				mapImageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, mapImageLoaded, false, 0, true);
			}else {
				mapImageLoader.unload();
			}
			mapImageLoader.load(new URLRequest(_mapView.mapData.getMapById(_mapView.mapData.currentMapId).path));
		}
		
		private function mapImageLost(e:Event):void {
			// TODO: retry 
		}
		
		private function mapImageLoaded(e:Event):void {
			_mapView.mapImage.bitmapData = (mapImageLoader.content as Bitmap).bitmapData;
			buildWaypoints();
		}
		
		private function buildWaypoints():void{
			while (_mapView.waypointsContainer.numChildren) {
				_mapView.waypointsContainer.removeChildAt(0);
			}
			while (waypointControlers.length) {
				waypointControlers.pop(); // TODO: is this right ? or should i nullify array
			}			
			var waypointView:WaypointView;
			var waypointController:WaypointController;
			for each(var waypoint:Waypoint in  _mapView.mapData.getMapById(_mapView.mapData.currentMapId).getChildrenOfGivenClass(Waypoint)) {
				waypointView = new WaypointView(new WaypointData(waypoint));				
				_mapView.waypointsContainer.addChild(waypointView);
				waypointController = new WaypointController(waypointView, _module);
				waypointControlers.push(waypointController);
			}
		}
	}
}