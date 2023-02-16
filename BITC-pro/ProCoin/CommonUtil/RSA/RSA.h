//
//  RSA.h
//  TJRtaojinroad
//
//  Created by taojinroad on 15/8/31.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSA : NSObject{
    SecKeyRef publicKey;
    SecCertificateRef certificate;
    SecPolicyRef policy;
    SecTrustRef trust;
    size_t maxPlainLen;
}

- (id)initWithKeyFile:(NSString*)file;

- (NSData *) encryptWithData:(NSData *)content;

- (NSData *) encryptWithString:(NSString *)content;
@end

