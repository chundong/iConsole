//
//  HelloWorldViewController.m
//  HelloWorld
//
//  Created by Nick Lockwood on 10/03/2010.
//  Copyright Charcoal Design 2010. All rights reserved.
//

#import "HelloWorldViewController.h"
#import "iConsole.h"
#import <objc/objc.h>
#import <objc/runtime.h>
#import <objc/message.h>
//#import "
//http://stackoverflow.com/questions/19694173/using-objective-cs-invoke-method-to-call-a-void-method-under-arc
static void (*_method_invoke_void)(id, Method, ...) = (void (*)(id, Method, ...)) method_invoke;
static id (*_method_invoke_id)(id, Method, ...) = (id (*)(id, Method, ...)) method_invoke;
//
//_method_invoke_void(target, method);

@implementation HelloWorldViewController

- (IBAction)sayHello:(id)sender
{	
	NSString *text = _field.text;
	if ([text isEqualToString:@""])
	{
		text = @"World";
	}
	
	_label.text = [NSString stringWithFormat:@"Hello %@", text];
	[iConsole info:@"Said '%@'", _label.text];
}

- (IBAction)crash:(id)sender
{
	[[NSException exceptionWithName:@"HelloWorldException" reason:@"Demonstrating crash logging" userInfo:nil] raise];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [iConsole sharedConsole].delegate = self;
	
	NSUInteger touches = (TARGET_IPHONE_SIMULATOR ? [iConsole sharedConsole].simulatorTouchesToShow: [iConsole sharedConsole].deviceTouchesToShow);
	if (touches > 0 && touches < 11)
	{
		self.swipeLabel.text = [NSString stringWithFormat:
								@"\nSwipe up with %zd finger%@ to show the console",
								touches, (touches != 1)? @"s": @""];
	}
	else if (TARGET_IPHONE_SIMULATOR ? [iConsole sharedConsole].simulatorShakeToShow: [iConsole sharedConsole].deviceShakeToShow)
	{
		self.swipeLabel.text = @"\nShake device to show the console";
	}
							
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{	
	[textField resignFirstResponder];
	[self sayHello:self];
	return YES;
}

- (void)handleConsoleCommand:(NSString *)command
{
    //command = @"-v.ctl.hello"
	if ([command isEqualToString:@"version"])
	{
		[iConsole info:@"%@ version %@",
         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"],
		 [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
	}
    else if([command hasPrefix:@"-"]) // for instance method
    {
        NSArray* cmds = [command componentsSeparatedByString:@"."];
        NSDictionary* _bindObject= [iConsole sharedConsole].bindObjects;
        if (_bindObject)
        {
            NSObject* obj = _bindObject[cmds[1]];
            SEL selector = sel_registerName([cmds[2] UTF8String]);
            
            Method m = class_getInstanceMethod([obj class],selector);
            
            if (m)
            {
                //eg command =  @"-v.ctl.hello"; 返回空
                if ([cmds[0] hasPrefix:@"-v"] )
                {
                    _method_invoke_void(obj,m);
                }else if ([cmds[0] hasPrefix:@"-o"] )
                {
                    //eg command =  @"-o.ctl.hello"; 返回obj对象
                    NSObject* retObj = _method_invoke_id(obj, m);
                    [iConsole info:@"retObj = %@",retObj];
                }

            }
        }
    }
    else if([command hasPrefix:@"+"]){ //TODO command = @"-v.ctl.hello"  for class Method
        
    }
	else{
		[iConsole error:@"unrecognised command, try 'version' instead"];
        
	}
}

- (void)hello
{
    [iConsole info:@"hello"];
}
- (NSString*)world
{
    [iConsole info:@"world"];
    return @"world";
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    
	self.label = nil;
	self.field = nil;
	self.swipeLabel = nil;
}

@end
