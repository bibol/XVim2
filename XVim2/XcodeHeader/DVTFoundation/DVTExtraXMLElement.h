//
//     Generated by class-dump 3.5 (64 bit) (Debug version compiled Sep 30 2020 21:18:12).
//
//  Copyright (C) 1997-2019 Steve Nygard.
//

#import <objc/NSObject.h>

@class NSMutableArray, NSString;

@interface DVTExtraXMLElement : NSObject
{
    NSString *_name;
    NSMutableArray *_mutableAttributeNames;
    NSMutableArray *_mutableAttributeValues;
    NSMutableArray *_mutableElements;
}

- (void).cxx_destruct;
@property(readonly) NSMutableArray *mutableElements; // @synthesize mutableElements=_mutableElements;
@property(readonly) NSMutableArray *mutableAttributeValues; // @synthesize mutableAttributeValues=_mutableAttributeValues;
@property(readonly) NSMutableArray *mutableAttributeNames; // @synthesize mutableAttributeNames=_mutableAttributeNames;
@property(copy) NSString *name; // @synthesize name=_name;
- (id)init;

@end

