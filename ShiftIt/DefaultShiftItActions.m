/*
 ShiftIt: Resize windows with Hotkeys
 Copyright (C) 2010  Filip Krikava
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
 */

#import "DefaultShiftItActions.h"
#import "FMTDefines.h"

NSRect ShiftIt_Left(NSSize screenSize, NSRect windowRect) {
	NSRect r;
	
	r.origin.x = 0;
	r.origin.y = 0;
	
	r.size.width = screenSize.width / 2;
	r.size.height = screenSize.height;
	
	return r;
}

NSRect ShiftIt_Right(NSSize screenSize, NSRect windowRect) {
	NSRect r;
	
	r.origin.x = screenSize.width/2;
	r.origin.y = 0;
	
	r.size.width = screenSize.width / 2;
	r.size.height = screenSize.height;

	return r;
}

NSRect ShiftIt_Top(NSSize screenSize, NSRect windowRect) {
	NSRect r;
	
	r.origin.x = 0;
	r.origin.y = 0;
	
	r.size.width = screenSize.width;
	r.size.height = screenSize.height / 2;
	
	return r;
}

NSRect ShiftIt_Bottom(NSSize screenSize, NSRect windowRect) {
	NSRect r;
	
	r.origin.x = 0;
	r.origin.y = screenSize.height / 2;
	
	r.size.width = screenSize.width;
	r.size.height = screenSize.height / 2;
	
	return r;
}

NSRect ShiftIt_Left_One_Third(NSSize screenSize, NSRect windowRect) {
  NSRect r;
  
  r.origin.x = 0;
  r.origin.y = 0;
  
  r.size.width = screenSize.width / 3;
  r.size.height = screenSize.height;
  
  return r;
}

NSRect ShiftIt_Left_Two_Thirds(NSSize screenSize, NSRect windowRect) {
  NSRect r;
  
  r.origin.x = 0;
  r.origin.y = 0;
  
  r.size.width = 2 * screenSize.width / 3;
  r.size.height = screenSize.height;
  
  return r;
}

NSRect ShiftIt_Middle_One_Third(NSSize screenSize, NSRect windowRect) {
  NSRect r;
  
  r.origin.x = screenSize.width / 3;
  r.origin.y = 0;
  
  r.size.width = screenSize.width / 3;
  r.size.height = screenSize.height;
  return r;
}

NSRect ShiftIt_Right_Two_Thirds(NSSize screenSize, NSRect windowRect) {
  NSRect r;
  
  r.origin.x = screenSize.width / 3;
  r.origin.y = 0;
  
  r.size.width = 2 * screenSize.width / 3;
  r.size.height = screenSize.height;
  return r;
}

NSRect ShiftIt_Right_One_Third(NSSize screenSize, NSRect windowRect) {
  NSRect r;
  
  r.origin.x = 2 * screenSize.width / 3;
  r.origin.y = 0;
  
  r.size.width = screenSize.width / 3;
  r.size.height = screenSize.height;
  return r;
}

NSRect ShiftIt_TopLeft(NSSize screenSize, NSRect windowRect) {
	NSRect r;
	
	r.origin.x = 0;
	r.origin.y = 0;
	
	r.size.width = screenSize.width / 2;
	r.size.height = screenSize.height / 2;
	
	return r;
}

NSRect ShiftIt_TopRight(NSSize screenSize, NSRect windowRect) {
	NSRect r;
	
	r.origin.x = screenSize.width / 2;
	r.origin.y = 0;
	
	r.size.width = screenSize.width / 2;
	r.size.height = screenSize.height / 2;
	
	return r;
}

NSRect ShiftIt_BottomLeft(NSSize screenSize, NSRect windowRect) {
	NSRect r;
	
	r.origin.x = 0;
	r.origin.y = screenSize.height / 2;
	
	r.size.width = screenSize.width / 2;
	r.size.height = screenSize.height / 2;
	
	return r;
}

NSRect ShiftIt_BottomRight(NSSize screenSize, NSRect windowRect) {
	NSRect r;
	
	r.origin.x = screenSize.width / 2;
	r.origin.y = screenSize.height / 2;
	
	r.size.width = screenSize.width / 2;
	r.size.height = screenSize.height / 2;
	
	return r;
}

NSRect ShiftIt_BottomLeft_One_Quarter(NSSize screenSize, NSRect windowRect) {
	NSRect r;
	
	r.origin.x = 0;
	r.origin.y = 3 * screenSize.height / 4;
	
	r.size.width = screenSize.width / 2;
	r.size.height = screenSize.height / 4;
	
	return r;
}

NSRect ShiftIt_BottomRight_One_Quarter(NSSize screenSize, NSRect windowRect) {
	NSRect r;
	
	r.origin.x = screenSize.width / 2;
	r.origin.y = 3 * screenSize.height / 4;
	
	r.size.width = screenSize.width / 2;
	r.size.height = screenSize.height / 4;
	
	return r;
}

NSRect ShiftIt_FullScreen(NSSize screenSize, NSRect windowRect) {
	NSRect r;
	
	r.origin.x = 0;
	r.origin.y = 0;
	
	r.size.width = screenSize.width;
	r.size.height = screenSize.height;
	
	return r;
}

NSRect ShiftIt_Center(NSSize screenSize, NSRect windowRect) {
	NSRect r;
	
	r.origin.x = (screenSize.width / 2)-(windowRect.size.width / 2);
	r.origin.y = (screenSize.height / 2)-(windowRect.size.height / 2);	
	
	r.size = windowRect.size;
	
	return r;
}
