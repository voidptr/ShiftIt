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

#include <assert.h>
#include <stdio.h>
#include <X11/Xlib.h>
#include <X11/Xatom.h>

#include "X11Utils.h"

static const char *const kErrorMessages_[] = {
	"X11Error: Unable to to connect to X11 display",
	"X11Error: Unable to get active window (XGetWindowProperty)",
	"X11Error: No X11 active window found",
	"X11Error: Unable to get window attributes (XGetWindowAttributes)",
	"X11Error: Unable to translate coordinated (XTranslateCoordinates)",
	"X11Error: Unable to get geometry (XGetGeometry)",
	"X11Error: Unable to change window geometry (XMoveResizeWindow)",
	"X11Error: Unable to sync X11 (XSync)"
};

static int kErrorMessageCount_ = sizeof(kErrorMessages_)/sizeof(kErrorMessages_[0]);

static int ShiftItX11ErrorHandler(Display *dpy, XErrorEvent *err) {
	char msg[256];
	
	XGetErrorText(dpy, err->error_code, msg, sizeof(msg));
	printf("ShiftIt: X11Error: %s (code: %d)\n", msg, err->request_code);
		
	return 0;
}

int X11SetWindowPosition(void *window, int x, int y) {
	assert (window != NULL);
	
	Display *dpy = XOpenDisplay(NULL);
	
	if (!dpy) {
		return -1;
	}
	
	XSetErrorHandler(&ShiftItX11ErrorHandler);
	
	// we don't need to adjust the x and y since they are from the top left window	
	if (!XMoveWindow(dpy, *((Window *)window), x, y)){
		return -6;
	}
	
	// do it now - this will block
	if (!XSync(dpy, False)) {
		return -7;
	}
	
	XCloseDisplay(dpy);
	return 0;	
}

int X11SetWindowSize(void *window, unsigned int width, unsigned int height) {
	assert (window != NULL);
	
	Display *dpy = XOpenDisplay(NULL);
	
	if (!dpy) {
		return -1;
	}
	
	XSetErrorHandler(&ShiftItX11ErrorHandler);
	
	XWindowAttributes wa;
    if(!XGetWindowAttributes(dpy, *((Window *)window), &wa)) {
		return -4;
	}
	
	// the WindowSizer will pass the size of the entire window including its decoration
	// we need to subtract that
	width -= wa.x;
	height -= wa.y;
		
	if (!XResizeWindow(dpy, *((Window *)window), width, height)){
		return -6;
	}
	
	if (!XSync(dpy, False)) {
		return -7;
	}
	
	XCloseDisplay(dpy);
	return 0;
}

int X11GetActiveWindow(void **activeWindow) {
	Display* dpy = NULL;
	dpy = XOpenDisplay(NULL);
	
	if (!dpy) {
		return -1;
	}
	
	XSetErrorHandler(&ShiftItX11ErrorHandler);
	
	Window root = DefaultRootWindow(dpy);
	
	// following are for the params that are not used
	int not_used_int;
	unsigned long not_used_long;
	
	Atom actual_type = 0;
	unsigned char *prop_return = NULL;
	
	if(XGetWindowProperty(dpy, root, XInternAtom(dpy, "_NET_ACTIVE_WINDOW", False), 0, 0x7fffffff, False,
						  XA_WINDOW, &actual_type, &not_used_int, &not_used_long, &not_used_long,
						  &prop_return) != Success) {
		return -2;
	}
	
	if (prop_return == NULL || *((Window *) prop_return) == 0) {
		return -3;
	}
	
	*activeWindow = (void *) prop_return;	
	
	XCloseDisplay(dpy);
	return 0;
}

int X11GetWindowGeometry(void *window, int *x, int *y, unsigned int *width, unsigned int *height) {
	assert (x != NULL && y != NULL && width != NULL && height != NULL);

	Display* dpy = NULL;
	dpy = XOpenDisplay(NULL);
	
	if (!dpy) {
		return -1;
	}
	
	XSetErrorHandler(&ShiftItX11ErrorHandler);

	Window root = DefaultRootWindow(dpy);
	XWindowAttributes wa;
	
    if(!XGetWindowAttributes(dpy, *((Window *)window), &wa)) {
		return -4;
	}
	
	Window not_used_window;
	if(!XTranslateCoordinates(dpy, *((Window *)window), root, -wa.border_width, -wa.border_width, x, y, &not_used_window)) {
		return -5;
	}
	
	// the height returned is without the window manager decoration - the OSX top bar with buttons, window label and stuff
	// so we need to add it to the height as well because the WindowSize expects the full window
	// the same might be potentially apply to the width
	*width = wa.width + wa.x;
	*height = wa.height + wa.y;
	
	*x -= wa.x;
	*y -= wa.y;
	
	XCloseDisplay(dpy);	
	return 0;	
}

void X11FreeWindowRef(void *window) {
	assert(window != NULL);
	
	XFree(window);
}

const char *X11GetErrorMessage(int code) {
	assert (code < 0 && code >= -kErrorMessageCount_);

	return kErrorMessages_[-code-1];
}
