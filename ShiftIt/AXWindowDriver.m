//
//  AXWindowManager.m
//  ShiftIt
//
//  Created by Filip Krikava on 8/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AXWindowDriver.h"
#import "ShiftIt.h"
#import "FMTDefines.h"

// from whatever reason this attribute is missing in the AXAttributeConstants.h
#define kAXFullScreenAttribute  CFSTR("AXFullScreen")

#pragma mark Logging Utils

#define AX_COPY_ATTR_ERROR(attr, ret) SICreateError(kAXFailureErrorCode, @"AXUIElementCopyAttributeValue failure: attribute: %@ error: %d", @#attr, (ret))
#define AX_SET_ATTR_ERROR(attr, ret) SICreateError(kAXFailureErrorCode, @"AXUIElementSetAttributeValue failure: attribute: %@ error: %d", @#attr, (ret))
#define AX_PERF_ACTION_ERROR(action, ret) SICreateError(kAXFailureErrorCode, @"AXUIElementPerformAction failure: action: %@ error: %d", @#action, (ret))
#define AX_IS_ATTR_SETTABLE_ERROR(attr, ret) SICreateError(kAXFailureErrorCode, @"AXUIElementIsAttributeSettable failure: action: %@ error: %d", @#attr, (ret))
#define AX_VALUE_TYPE_ERROR(expected, actual) SICreateError(kAXFailureErrorCode, @"AXTypeError: expected: %@ actual: %@", @#expected, (actual))

#pragma mark Constants

NSInteger const kAXFailureErrorCode = 20102;
NSInteger const kAXWindowDriverErrorCode = 20104;

const double kDelay = 0.25;

#pragma mark AX Utils

@interface AXWindowDriver(AXUtils)
+ (BOOL) getFocusedWindow_:(AXUIElementRef *)windowRef ofApplication:(AXUIElementRef)applicationRef error:(NSError **)error;

+ (BOOL) canAttribute_:(CFStringRef)attributeName ofElement:(AXUIElementRef)element change:(BOOL *)changeable error:(NSError **)error;
+ (BOOL) isAttribute_:(CFStringRef)attributeName ofElement:(AXUIElementRef)element present:(BOOL *)flag error:(NSError **)error;
+ (BOOL) pressButton_:(CFStringRef)buttonName ofElement:(AXUIElementRef)element error:(NSError **)error;

+ (BOOL) getOrigin_:(NSPoint *)origin ofElement:(AXUIElementRef)element error:(NSError **)error;
+ (BOOL) getSize_:(NSSize *)size ofElement:(AXUIElementRef)element error:(NSError **)error;
+ (BOOL) getDrawersGeometry_:(NSRect *)geometry ofElement:(AXUIElementRef)windowRef error:(NSError **)error;

+ (BOOL) setSize_:(NSSize)size ofElement:(AXUIElementRef)element error:(NSError **)error;
+ (BOOL) setOrigin_:(NSPoint)origin ofElement:(AXUIElementRef)element error:(NSError **)error;

@end

#pragma mark AXWindow

@interface AXWindow : NSObject<SIWindow> {
@private
    AXUIElementRef ref_;
    AXWindowDriver *driver_;
}

@property (readonly) AXUIElementRef ref_;
@property (readonly) AXWindowDriver *driver_;

- (id) initWithRef:(AXUIElementRef)ref
            driver:(AXWindowDriver *)driver;

@end

#pragma mark Window Delegate Functions

@interface AXWindowDriver(WindowDelegate)

- (BOOL) getGeometry_:(NSRect *)geometry windowRect:(NSRect *)windowRect drawersRect:(NSRect *)drawersRect ofWindow:(AXUIElementRef)windowRef error:(NSError **)error;
- (BOOL) setGeometry_:(NSRect)geometry ofWindow:(AXUIElementRef)windowRef error:(NSError **)error;
- (void) freeWindow_:(AXUIElementRef)windowRef;
- (BOOL) getFullScreen_:(BOOL *)fullScreen ofWindow:(AXUIElementRef)windowRef error:(NSError **)error;
- (BOOL) toggleZoomOfWindow_:(AXUIElementRef)windowRef error:(NSError **)error;
- (BOOL) toggleFullScreenOfWindow_:(AXUIElementRef)windowRef error:(NSError **)error;
- (BOOL) canResize_:(BOOL *)flag window:(AXUIElementRef)windowRef error:(NSError **)error;
- (BOOL) canMove_:(BOOL *)flag window:(AXUIElementRef)windowRef error:(NSError **)error;
- (BOOL) canZoom_:(BOOL *)flag window:(AXUIElementRef)windowRef error:(NSError **)error;
- (BOOL) canEnterFullScreen_:(BOOL *)flag window:(AXUIElementRef)windowRef error:(NSError **)error;

@end

#pragma mark AXWindow Implementation

@implementation AXWindow

@synthesize ref_;
@synthesize driver_;

- (id) initWithRef:(AXUIElementRef)ref 
            driver:(AXWindowDriver *)driver {
    
	FMTAssertNotNil(ref);
	FMTAssertNotNil(driver);
    
	if (![super init]) {
		return nil;
	}
    
    // TODO: check th eownership policy for Core Foundation
	ref_ = ref;
    driver_ = [driver retain];
    
	return self;
}

- (void) dealloc {
    [driver_ freeWindow_:ref_];
    
    [driver_ release];
    
	[super dealloc];
}

- (BOOL) getGeometry:(NSRect *)geometry error:(NSError **)error {
    FMTAssertNotNil(geometry);
    FMTAssertNotNil(error);
    
    NSRect unused;
    
    return [driver_ getGeometry_:geometry windowRect:&unused drawersRect:&unused ofWindow:ref_ error:error];            
}

- (BOOL) getWindowRect:(NSRect *)windowRect drawersRect:(NSRect *)drawersRect error:(NSError **)error {
    FMTAssertNotNil(windowRect);
    FMTAssertNotNil(drawersRect);
    FMTAssertNotNil(error);
    
    NSRect unused;
    
    return [driver_ getGeometry_:&unused windowRect:windowRect drawersRect:drawersRect ofWindow:ref_ error:error];                
}


- (BOOL) getScreen:(SIScreen **)screen error:(NSError **)error {
    FMTAssertNotNil(screen);
    FMTAssertNotNil(error);

    NSRect geometry;
    
    if (![self getGeometry:&geometry error:error]) {
        return NO;
    }
    
    *screen = [SIScreen screenForWindowGeometry:geometry];
    return YES;
}

- (BOOL) setGeometry:(NSRect)geometry error:(NSError **)error {
    return [driver_ setGeometry_:geometry ofWindow:ref_ error:error];
}

- (BOOL) canZoom:(BOOL *)flag error:(NSError **)error {
    return [driver_ canZoom_:flag window:ref_ error:error];
}

- (BOOL) canEnterFullScreen:(BOOL *)flag error:(NSError **)error {
    return [driver_ canEnterFullScreen_:flag window:ref_ error:error];    
}

- (BOOL) canMove:(BOOL *)flag error:(NSError **)error {
    return [driver_ canMove_:flag window:ref_ error:error];
}

- (BOOL) canResize:(BOOL *)flag error:(NSError **)error {
    return [driver_ canResize_:flag window:ref_ error:error];    
}

- (BOOL) getFullScreen:(BOOL *)flag error:(NSError **)error {
    return [driver_ getFullScreen_:flag ofWindow:ref_ error:error];
}

- (BOOL) toggleFullScreen:(NSError **)error {
    return [driver_ toggleFullScreenOfWindow_:ref_ error:error];
}

- (BOOL) toggleZoom:(NSError **)error {
    return [driver_ toggleZoomOfWindow_:ref_ error:error];    
}

@end

#pragma mark AX Window Driver Implementation

@implementation AXWindowDriver

@synthesize shouldUseDrawers = shouldUseDrawers_;
@synthesize numberOfTries = numberOfTries_;

- (id)init {
	if(![super init]){
		return nil;
	}
    
    systemElementRef_ = AXUIElementCreateSystemWide();
    // here is the assert for purpose because the app should not have gone 
	// that far in execution if the AX api is not available
	FMTAssertNotNil(systemElementRef_);
    
    return self;
}

- (void) dealloc {
    CFRelease(systemElementRef_);
}

- (BOOL) findFocusedWindow:(id<SIWindow> *)window withInfo:(SIWindowInfo *)windowInfo error:(NSError **)error {
	FMTAssertNotNil(error);

    AXUIElementRef appRef = AXUIElementCreateApplication([windowInfo pid]);
    if (appRef == nil) {
        *error = SICreateError(kAXFailureErrorCode, @"Unable to create AXUIElementRef for the application with PID: %d", [windowInfo pid]);
        return NO;
    }
    
    AXUIElementRef windowRef;
    //get the focused window
    if (![AXWindowDriver getFocusedWindow_:&windowRef ofApplication:appRef error:error]) {
        CFRelease(appRef);
        return NO;
    }
    
    *window = [[[AXWindow alloc] initWithRef:windowRef driver:self] autorelease];
    
    CFRelease(appRef);
    return YES;    
}

@end

#pragma mark Utility Functions Implementation

@implementation AXWindowDriver (AXUtils)

+ (BOOL) getFocusedWindow_:(AXUIElementRef *)windowRef ofApplication:(AXUIElementRef)applicationRef error:(NSError **)error {
    FMTAssertNotNil(windowRef);
    FMTAssertNotNil(applicationRef);
    FMTAssertNotNil(error);
    
    AXError ret = kAXFailureErrorCode;
    
    if ((ret = AXUIElementCopyAttributeValue(applicationRef,
                                             kAXFocusedWindowAttribute,
                                             (CFTypeRef *) windowRef)) != kAXErrorSuccess) {
        *error = AX_COPY_ATTR_ERROR(kAXFocusedWindowAttribute, ret);
        return NO;
    }
        
    return YES;
}

+ (BOOL) pressButton_:(CFStringRef)buttonName ofElement:(AXUIElementRef)element error:(NSError **)error {
    FMTAssertNotNil(buttonName);
    FMTAssertNotNil(element);
    FMTAssertNotNil(error);
    
    //get the focused application
    AXUIElementRef button = nil;
    AXError ret = 0;
    
    if ((ret = AXUIElementCopyAttributeValue(element,
                                             (CFStringRef) buttonName,
                                             (CFTypeRef *) &button)) != kAXErrorSuccess) {
        *error = AX_COPY_ATTR_ERROR((NSString *)buttonName, ret);
        return NO;
    }
    
    FMTAssertNotNil(button);
    
    if ((ret = AXUIElementPerformAction(button, kAXPressAction)) != kAXErrorSuccess) {
        CFRelease(button);
        *error = AX_PERF_ACTION_ERROR(kAXPressAction, ret);
        return NO;        
    }
    
    CFRelease(button);
    return YES;    
}

+ (BOOL) isAttribute_:(CFStringRef)attributeName ofElement:(AXUIElementRef)element present:(BOOL *)flag error:(NSError **)error {
    FMTAssertNotNil(attributeName);
    FMTAssertNotNil(element);
    FMTAssertNotNil(flag);
    FMTAssertNotNil(error);
    
    CFTypeRef value;
    AXError ret = 0;
    
	if ((ret = AXUIElementCopyAttributeValue(element, kAXSizeAttribute, &value)) != kAXErrorSuccess) {
        *flag = NO;
		return YES;
	}
    
    CFRelease(value);
    *flag = YES;
    return YES;
}

+ (BOOL) canAttribute_:(CFStringRef)attributeName ofElement:(AXUIElementRef)element change:(BOOL *)changeable error:(NSError **)error {
    FMTAssertNotNil(attributeName);
    FMTAssertNotNil(element);
    FMTAssertNotNil(changeable);
    FMTAssertNotNil(error);
    
    Boolean isSettable = false;
    AXError ret = 0;
    
    if ((ret = AXUIElementIsAttributeSettable(element, (CFStringRef)attributeName, &isSettable)) != kAXErrorSuccess) {
        *error = AX_IS_ATTR_SETTABLE_ERROR((NSString *)attributeName, ret);
        return NO;
    }
    
    *changeable = isSettable == true ? YES : NO;
    
    return YES;
}

+ (BOOL) getOrigin_:(NSPoint *)origin ofElement:(AXUIElementRef)element error:(NSError **)error {
	FMTAssertNotNil(element);
	FMTAssertNotNil(origin);
	FMTAssertNotNil(error);
    
	CFTypeRef originRef;
    AXError ret = 0;
	
	if ((ret = AXUIElementCopyAttributeValue(element,kAXPositionAttribute, &originRef)) != kAXErrorSuccess) {
        *error = AX_COPY_ATTR_ERROR(kAXPositionAttribute, ret);
		return NO;
	}
	
	FMTAssertNotNil(originRef);
    
	if(AXValueGetType(originRef) == kAXValueCGPointType) {
		AXValueGetValue(originRef, kAXValueCGPointType, origin);
	} else {
		CFRelease(originRef);
        *error = AX_VALUE_TYPE_ERROR(kAXValueCGPointType, AXValueGetType(originRef));
		return NO;
	}
	
	CFRelease(originRef);
	return YES;
}

+ (BOOL) getSize_:(NSSize *)size ofElement:(AXUIElementRef)element error:(NSError **)error {
	FMTAssertNotNil(element);
	FMTAssertNotNil(size);
	FMTAssertNotNil(error);
    
	CFTypeRef sizeRef;
    AXError ret = 0;
    
	if ((ret = AXUIElementCopyAttributeValue(element, kAXSizeAttribute, &sizeRef)) != kAXErrorSuccess) {
        *error = AX_COPY_ATTR_ERROR(kAXSizeAttribute, ret);
		return NO;
	}
	
	FMTAssertNotNil(sizeRef);
    
	if(AXValueGetType(sizeRef) == kAXValueCGSizeType) {
		AXValueGetValue(sizeRef, kAXValueCGSizeType, size);
	} else {
        CFRelease(sizeRef);
        *error = AX_VALUE_TYPE_ERROR(kAXValueCGSizeType,AXValueGetType(sizeRef));
		return NO;
	}
	
	CFRelease(sizeRef);
	return YES;
}

+ (BOOL) getDrawersGeometry_:(NSRect *)geometry ofElement:(AXUIElementRef)windowRef error:(NSError **)error {
	FMTAssertNotNil(windowRef);
	FMTAssertNotNil(geometry);
	FMTAssertNotNil(error);
    
	NSArray *children = nil;
    AXError ret = 0;
    
    // by defult there are none
    *geometry = NSMakeRect(0, 0, 0, 0);
    
	if ((ret = AXUIElementCopyAttributeValue(windowRef, kAXChildrenAttribute, (CFTypeRef *)&children)) != kAXErrorSuccess) {
        *error = AX_COPY_ATTR_ERROR(kAXChildrenAttribute, ret);
		return NO;
	}
    
	NSRect r; // for the loop	
	BOOL first = YES;
    NSError *cause = nil;
    
	for (id child in children) {
		NSString *role = nil;
		
		if ((ret = AXUIElementCopyAttributeValue((AXUIElementRef)child, kAXRoleAttribute , (CFTypeRef*)&role)) != kAXErrorSuccess) {
            *error = AX_COPY_ATTR_ERROR(kAXRoleAttribute, ret);
            return NO;
        }
		
		if([role isEqualToString:NSAccessibilityDrawerRole]) {
			if (![AXWindowDriver getOrigin_:&(r.origin) ofElement:(AXUIElementRef)child error:&cause]) {
                *error = SICreateErrorWithCause(kWindowManagerFailureErrorCode, cause, @"AXError: Unable to position of a window drawer");
                return NO;                
            }
			if (![AXWindowDriver getSize_:&(r.size) ofElement:(AXUIElementRef)child error:&cause]) {
                *error = SICreateErrorWithCause(kWindowManagerFailureErrorCode, cause, @"AXError: Unable to size of a window drawer");
                return NO;                                
            }
            
			if (first) {
				*geometry = r;
				first = NO;
			} else {
				*geometry = NSUnionRect(*geometry, r);
			}
		}
		
		CFRelease((CFTypeRef) role);
	}
	
	[children release];
	return YES;
}

+ (BOOL) setSize_:(NSSize)size ofElement:(AXUIElementRef)element error:(NSError **)error {
    FMTAssertNotNil(element);
    FMTAssertNotNil(error);
    
    CFTypeRef sizeRef = (CFTypeRef)(AXValueCreate(kAXValueCGSizeType, (const void *)&size));
    AXError ret = 0;
    
    if ((ret = AXUIElementSetAttributeValue(element, kAXSizeAttribute, sizeRef)) != kAXErrorSuccess){
        *error = AX_SET_ATTR_ERROR(kAXSizeAttribute, ret);
        CFRelease(sizeRef);
        
        return NO;
    }		
    
    CFRelease(sizeRef);
    return YES;
}

+ (BOOL) setOrigin_:(NSPoint)origin ofElement:(AXUIElementRef)element error:(NSError **)error {
    FMTAssertNotNil(element);
    FMTAssertNotNil(error);
    
	CFTypeRef originRef = (CFTypeRef)(AXValueCreate(kAXValueCGPointType, (const void *)&origin));
    AXError ret = 0;
	
    if ((ret = AXUIElementSetAttributeValue(element, kAXPositionAttribute, originRef)) != kAXErrorSuccess) {
        CFRelease(originRef);
        *error = AX_SET_ATTR_ERROR(kAXPositionAttribute, ret);
        
        return NO;
    }          
    
    CFRelease(originRef);
    return YES;
}

@end

@implementation AXWindowDriver (WindowDelegate)

- (BOOL) getGeometry_:(NSRect *)geometryRef windowRect:(NSRect *)windowRectRef drawersRect:(NSRect *)drawersRectRef ofWindow:(AXUIElementRef)windowRef error:(NSError **)error {
    FMTAssertNotNil(windowRef);
    FMTAssertNotNil(geometryRef);
    FMTAssertNotNil(windowRectRef);
    FMTAssertNotNil(drawersRectRef);
    
    NSRect geometry = NSMakeRect(0, 0, 0, 0);
    NSRect windowRect = NSMakeRect(0, 0, 0, 0);
	NSRect drawersRect = NSMakeRect(0, 0, 0, 0);
    
    if (![AXWindowDriver getOrigin_:&(windowRect.origin) ofElement:windowRef error:error]) {
		return NO;
	}
    
	if (![AXWindowDriver getSize_:&(windowRect.size) ofElement:windowRef error:error]) {
		return NO;
	}
    
    if (shouldUseDrawers_) {
        NSError *cause = nil;
        if (![AXWindowDriver getDrawersGeometry_:&drawersRect ofElement:windowRef error:&cause]) {
            geometry = windowRect;
            FMTLogDebug(@"Unable to get window drawers: %@", [cause localizedDescription]);
        } else if (drawersRect.size.width > 0) {
            // there are some drawers            
            geometry = NSUnionRect(windowRect, drawersRect);
        } else {
            geometry = windowRect;
        }
    }
    
    *geometryRef = geometry;
    *windowRectRef = windowRect;
    *drawersRectRef = drawersRect;
    
    return YES;
}

// TODO: make sure that the origin makes sense
- (BOOL) setGeometry_:(NSRect)geometry ofWindow:(AXUIElementRef)windowRef error:(NSError **)error {
	FMTAssertNotNil(windowRef);
	FMTAssertNotNil(error);
    
    FMTLogDebug(@"Setting window geometry to: %@", RECT_STR(geometry));
    
    NSRect currentGeometry;
    NSRect windowRect;
    NSRect drawersRect;
    
    if (![self getGeometry_:&currentGeometry windowRect:&windowRect drawersRect:&drawersRect ofWindow:windowRef error:error]) {
        return NO;
    }
    
    BOOL hasDrawers = drawersRect.size.width > 0;
    
    if (hasDrawers) {
        FMTLogDebug(@"Window geometry without drawers: %@", RECT_STR(windowRect));
        FMTLogDebug(@"Drawers geometry: %@", RECT_STR(drawersRect));            
    }
    FMTLogDebug(@"Window geometry with drawers: %@", RECT_STR(currentGeometry));
    
    SIScreen *screen = [SIScreen screenForWindowGeometry:geometry];
    
	// STEP 1: readjust adjust the visibility
	// the geometry is the new application window geometry relative to the screen originating at [0,0]
	// we need to shift it accordingly that is to the origin of the best fit screen (screenRect) and
	// take into account the visible area of such a screen - menu, dock, etc. which is in the visibleScreenRect
    NSRect visibleScreenRect = [screen visibleRect];    
    
	geometry.origin.x += visibleScreenRect.origin.x;
	geometry.origin.y += visibleScreenRect.origin.y;// - ([screen isPrimary] ? GetMBarHeight() : 0);
	
	// we need to translate from cocoa coordinates
	FMTLogDebug(@"Setting window geometry after readjusting the visiblity: %@", RECT_STR(geometry));	

    // STEP 2: readjust the drawers
	// when moving the drawers are not taken into an account so need to manually
    // adjust the new position and size relative to the rect of drawers
    NSRect newGeometry = geometry;
	if (shouldUseDrawers_ && hasDrawers) {
        int dx = windowRect.origin.x - currentGeometry.origin.x;
        int dy = currentGeometry.origin.y - windowRect.origin.y;
        int dw = currentGeometry.size.width - windowRect.size.width;
        int dh = currentGeometry.size.height - windowRect.size.height;
        
		newGeometry.origin.x += dx;
		newGeometry.origin.y -= dy;
		newGeometry.size.width -= dw;
		newGeometry.size.height -= dh;
		
		FMTLogDebug(@"Target window geometry after drawers adjustment: %@", RECT_STR(newGeometry));
	}
    
    NSError *cause = nil;
    
    // MOVE
    if (!NSEqualPoints(currentGeometry.origin, newGeometry.origin)) {
        NSPoint lastTry;
        // workaround for: http://lists.apple.com/archives/accessibility-dev/2011/Aug/msg00031.html
        for (int i=1; i<=numberOfTries_; i++) {
            // try to resize
            FMTLogDebug(@"Moving to: %@ (%d. attempt)", POINT_STR(newGeometry.origin), i);
            if (![AXWindowDriver setOrigin_:newGeometry.origin ofElement:windowRef error:&cause]) {
                *error = SICreateErrorWithCause(kAXWindowDriverErrorCode, 
                                                cause, 
                                                @"Unable to set window origin to: %@", POINT_STR(newGeometry.origin));
                return NO;
            }
            
            // TODO: extract and turn into a semaphore
            [NSThread sleepForTimeInterval:kDelay];
            
            // see what has happened
            NSRect actual;
            NSRect unused;
            if (![self getGeometry_:&unused windowRect:&actual drawersRect:&unused ofWindow:windowRef error:&cause]) {
                *error = SICreateErrorWithCause(kAXWindowDriverErrorCode, 
                                                cause, 
                                                @"Unable to get window size");
                return NO;
            }        
            FMTLogDebug(@"Window moved to: %@ (%d. attempt)", POINT_STR(actual.origin), i);
            
            // compare to the expected
            if (NSEqualPoints(actual.origin, newGeometry.origin)) {
                break;
            } else if (i > 1 && (NSEqualPoints(actual.origin, lastTry))) {
                // it seems that more attempts wont change anything
                FMTLogDebug(@"The %d attempt is the same as %d so no effect", i, i-1);
                break;
            }
            lastTry = actual.origin;
        }
    } else {
        FMTLogDebug(@"New origin and existing window origin are the same - no action");        
    }
    
    // RESIZE
	if (!NSEqualSizes(currentGeometry.size, newGeometry.size)) {
        NSSize lastTry;
        // workaround for: http://lists.apple.com/archives/accessibility-dev/2011/Aug/msg00031.html
        for (int i=1; i<=numberOfTries_; i++) {
            // try to resize
            FMTLogDebug(@"Resizing to: %@ (%d. attempt)", SIZE_STR(newGeometry.size), i);
            if (![AXWindowDriver setSize_:newGeometry.size ofElement:windowRef error:&cause]) {
                *error = SICreateErrorWithCause(kAXWindowDriverErrorCode, 
                                                cause, 
                                                @"Unable to set window size to: %@", SIZE_STR(newGeometry.size));
                return NO;
            }
            
            // TODO: extract and turn into a semaphore
            [NSThread sleepForTimeInterval:kDelay];

            // see what has happened
            NSRect actual;
            NSRect unused;
            if (![self getGeometry_:&unused windowRect:&actual drawersRect:&unused ofWindow:windowRef error:&cause]) {
                *error = SICreateErrorWithCause(kAXWindowDriverErrorCode, 
                                                cause, 
                                                @"Unable to get window size");
                return NO;
            }        
            FMTLogDebug(@"Window resized to: %@ (%d. attempt)", SIZE_STR(actual.size), i);
            
            // compare to the expected
            if (NSEqualSizes(actual.size, newGeometry.size)) {
                break;
            } else if (i > 1 && (NSEqualSizes(actual.size, lastTry))) {
                // it seems that more attempts wont change anything
                FMTLogDebug(@"The %d attempt is the same as %d so no effect (likely a discretely sizing window)", i, i-1);
                break;
            }
            lastTry = actual.size;
        }
    } else {
        FMTLogDebug(@"New size and existing window size are the same - no action");        
    }
    
    return YES;
}

- (void) freeWindow_:(AXUIElementRef)windowRef {
    FMTAssertNotNil(windowRef);
    
    CFRelease(windowRef);
}

- (BOOL) getFullScreen_:(BOOL *)fullScreen ofWindow:(AXUIElementRef)windowRef error:(NSError **)error {
    FMTAssertNotNil(windowRef);
    FMTAssertNotNil(fullScreen);
	FMTAssertNotNil(error);
	
    CFBooleanRef fullScreenRef;
    AXError ret = 0;
    
    if ((ret = AXUIElementCopyAttributeValue(windowRef,
                                             (CFStringRef) kAXFullScreenAttribute,
                                             (CFTypeRef *) &fullScreenRef)) != kAXErrorSuccess) {
        
        *error = AX_COPY_ATTR_ERROR(kAXFullScreenAttribute, ret);
        return NO;
    }
    
    *fullScreen = fullScreenRef == kCFBooleanTrue ? YES : NO;
	CFRelease(fullScreenRef);
	
	return YES;
}

- (BOOL) toggleZoomOfWindow_:(AXUIElementRef)windowRef error:(NSError **)error {    
    // args asserted in the nested call
    return [AXWindowDriver pressButton_:kAXZoomButtonAttribute ofElement:windowRef error:error];
}

- (BOOL) toggleFullScreenOfWindow_:(AXUIElementRef)windowRef error:(NSError **)error {
    FMTAssertNotNil(windowRef);
	FMTAssertNotNil(error);
	
    BOOL fullScreen = NO;
    NSError *cause = nil;
    if(![self getFullScreen_:&fullScreen ofWindow:windowRef error:&cause]) {
        *error = SICreateErrorWithCause(kWindowManagerFailureErrorCode, cause, @"AXError: Unable to determine whether window is in full screen or not");
        return NO;
    }
    
    AXError ret = 0;
	
    if ((ret = AXUIElementSetAttributeValue(windowRef, 
                                            kAXFullScreenAttribute, 
                                            fullScreen ? kCFBooleanFalse : kCFBooleanTrue)) != kAXErrorSuccess){
        *error = AX_SET_ATTR_ERROR(kAXFullScreenAttribute, ret);
        return NO;
	}		
    
    return YES;
}


- (BOOL) canResize_:(BOOL *)flag window:(AXUIElementRef)windowRef error:(NSError **)error {
    // args asserted in the nested call
    if (![AXWindowDriver canAttribute_:kAXSizeAttribute ofElement:windowRef change:flag error:error]) {
		return NO;
    }
    
    return YES;
}

- (BOOL) canMove_:(BOOL *)flag window:(AXUIElementRef)windowRef error:(NSError **)error {
    // args asserted in the nested call
    if (![AXWindowDriver canAttribute_:kAXPositionAttribute ofElement:windowRef change:flag error:error]) {
		return NO;
    }
    
    return YES;
}

- (BOOL) canZoom_:(BOOL *)flag window:(AXUIElementRef)windowRef error:(NSError **)error {
    // args asserted in the nested call
    if (![AXWindowDriver isAttribute_:kAXZoomButtonAttribute ofElement:windowRef present:flag error:error]) {
		return NO;
    }
    
    return YES;
}

- (BOOL) canEnterFullScreen_:(BOOL *)flag window:(AXUIElementRef)windowRef error:(NSError **)error {
    // args asserted in the nested call
    if (![AXWindowDriver canAttribute_:kAXFullScreenAttribute ofElement:windowRef change:flag error:error]) {
		return NO;
    }
    
    return YES;
}


@end