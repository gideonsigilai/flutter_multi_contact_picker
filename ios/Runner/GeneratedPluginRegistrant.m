//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<flutter_contacts/FlutterContactsPlugin.h>)
#import <flutter_contacts/FlutterContactsPlugin.h>
#else
@import flutter_contacts;
#endif

#if __has_include(<flutter_contacts_service/FlutterContactsServicePlugin.h>)
#import <flutter_contacts_service/FlutterContactsServicePlugin.h>
#else
@import flutter_contacts_service;
#endif

#if __has_include(<permission_handler_apple/PermissionHandlerPlugin.h>)
#import <permission_handler_apple/PermissionHandlerPlugin.h>
#else
@import permission_handler_apple;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [FlutterContactsPlugin registerWithRegistrar:[registry registrarForPlugin:@"FlutterContactsPlugin"]];
  [FlutterContactsServicePlugin registerWithRegistrar:[registry registrarForPlugin:@"FlutterContactsServicePlugin"]];
  [PermissionHandlerPlugin registerWithRegistrar:[registry registrarForPlugin:@"PermissionHandlerPlugin"]];
}

@end
