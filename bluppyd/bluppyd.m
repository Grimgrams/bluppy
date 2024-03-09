#import <Foundation/Foundation.h>
#import <libpq-fe.h>
#import <stdio.h>

/*
 *
 * I know putting this in one file is not good but I didn't think it would get this big :/
 * Maybe i'll fix it soon...
 */

@interface Logger : NSObject
    -(void)logMessage:(NSString *)message;
@end

@implementation Logger {
    NSFileHandle *_fileHandle;
}
-(instancetype)init {
    self = [super init];
    if (self){
        // Get logfile path
        NSString *filepath = [self getLogFilePath];

        if (![[NSFileManager defaultManager] fileExistsAtPath:filepath]){
            [[NSFileManager defaultManager] createFileAtPath:filepath contents:nil attributes:nil];
        }
        _fileHandle = [NSFileHandle fileHandleForWritingAtPath:filepath];
        [_fileHandle seekToEndOfFile];
    }
    return self;
}

- (NSString *)getLogFilePath {
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString* documentsDirectory = [paths objectAtIndex:0];
    //return [documentsDirectory stringByAppendingPathComponent:@"StatusLog.log"];
    NSString* homeDirectory = NSHomeDirectory();
    return  [homeDirectory stringByAppendingPathComponent:@".serverStatus.log"];
}

-(void)logMessage:(NSString *)message {
    [_fileHandle writeData:[[message stringByAppendingString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)dealloc{
    [_fileHandle closeFile];
    [super dealloc];
}

@end

const char *conninfo = "host=localhost dbname=bluppy user=grimgram password=";

void storeLastStatus(const char *lastStatus,const char *address,const char *date){
    PGconn *conn = PQconnectdb(conninfo);
    if (PQstatus(conn) == CONNECTION_BAD){
        // Debugging
        NSLog(@"Connection failed: %s", PQerrorMessage(conn));
        PQfinish(conn);
    } else {
        // Debugging
        NSLog(@"Connection to PostgreSQL");
    }

    //char updateStatusQuery[325];
   // sprintf(updateStatusQuery, "UPDATE statuses SET status = '%s', date = '%s' WHERE address = '%s'", lastStatus, date, address);

   /*
    printf("%s, %s, %s", lastStatus, date, address);
    NSString *query = @"UPDATE statuses SET status = $1, date = $2 WHERE address = $3";
    const char *params[3] = {lastStatus, date, address};
    int paramLengths[3] = {strlen(lastStatus), strlen(date), strlen(address)};
    int paramFormats[3] = {0, 0, 0};
    PGresult *result = PQexecParams(conn, query.UTF8String, 3, NULL, params, paramLengths, paramFormats, 0);
   // NSLog(@"%@", result);
    if (PQresultStatus(result) != PGRES_TUPLES_OK){
        // Debugging
        NSLog(@"Error Executing Query: %s", PQerrorMessage(conn));
        //PQclear(result);
        PQfinish(conn);
    } else {
        // Debugging
        NSLog(@"Table Updated Successfully!");
    }*/
    printf("HOW DIS GET HERE??: %s, %s, %s", lastStatus, date, address);
    NSString* _lastStatus = [NSString stringWithUTF8String:lastStatus];
    NSString* _address = [NSString stringWithUTF8String:address];
    NSString* _date = [NSString stringWithUTF8String:date];
    NSString* logStatus =[NSString stringWithFormat:@"%@: %@, [%@]", _lastStatus, _address, _date];
    Logger *logger = [[Logger alloc] init];
    [logger logMessage:logStatus];
    //[logger logMessage:@"Test2"];
    //NSLog(@"Logged File");
}

void pingServer(const char* address) {
    NSString* host = [NSString stringWithUTF8String:address];

    NSTask *pingTask = [[NSTask alloc] init];
    pingTask.launchPath = @"/sbin/ping";
    pingTask.arguments = @[@"-c", @"3", host];

    NSPipe *outPipe = [[NSPipe alloc] init];
    pingTask.standardOutput = outPipe;
    [pingTask launch];
    [pingTask waitUntilExit];

    NSFileHandle *fileHandle = [outPipe fileHandleForReading];
    NSData *data = [fileHandle readDataToEndOfFile];

    NSString *pingOutput = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    // Debugging
    //NSLog(@"Ping Out: %@", pingOutput);
    
    [pingTask release];
    [outPipe release];

    NSString *statusPattern = @"\\s0\\.0%\\spacket\\sloss";

    NSError *RGerror = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:statusPattern options:0 error:&RGerror];

    if (RGerror){
        NSLog(@"Error creating REGEX: %@", RGerror.localizedDescription);
        return;
    }

    [regex enumerateMatchesInString:pingOutput options:0 range:NSMakeRange(0, pingOutput.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange matchRange = result.range;
        NSString *matchedLine = [pingOutput substringWithRange:matchRange];
        //Debugging
        //NSLog(@"Matched Line: %@", matchedLine);

        NSDate *currentDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
        NSString *formattedDateString = [dateFormatter stringFromDate:currentDate];

        const char* address_ = [host UTF8String];
        const char* date_ = [formattedDateString UTF8String];
        [dateFormatter release];
        [pingOutput release];

        const char* servStatus;
        if (matchedLine){
            const char* latestStatus = "RUNNING";
            storeLastStatus(latestStatus,address_,date_);

        } else {
            storeLastStatus("NOT RUNNING",address_,date_);

        }



    }];


}

void getLatestStatus(void) {

    PGconn *conn = PQconnectdb(conninfo);

    PGresult *addrResult = PQexec(conn, "SELECT address FROM addresses");

    int numRows = PQntuples(addrResult);

    for (int i = 0; i < numRows; ++i) {
        const char *address = PQgetvalue(addrResult, i, 0);
        // Debugging
        //NSLog(@"IP: %s", address);
       pingServer(address);

    }

    PQclear(addrResult);
}

@interface BluppyDaemon : NSObject

@end

@implementation BluppyDaemon

- (void)start{
    
   while(true){
   sleep(25200);
   getLatestStatus();
   }
    
}

@end

int main(int argc, const char* argv[]){
    @autoreleasepool {
        BluppyDaemon *daemon = [[BluppyDaemon alloc] init];
        [daemon start];
        //getLatestStatus();
    }
    return 0;
}

