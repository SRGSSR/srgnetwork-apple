Getting started
===============

This getting started guide discusses all concepts required to use the SRG Network library, from basic requests to request group management with queues.

## Requests

At its core, SRG Network is all about requests. The simplest kind of request is `SRGRequest`, which you instantiate with an `NSURLRequest`, and start by calling `-resume`:

```objective-c
NSURLRequest *URLRequest = ...;
SRGRequest *request = [SRGRequest dataRequestWithURLRequest:URLRequest session:NSURLSession.sharedSession completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    if (error) {
        // Deal with the error
        return;
    }
    
    // Proceed further, e.g. display the content
}];
[request resume];
```

When a request ends, the corresponding completion block is called (on the main thread by default), with the returned data or error information. The completion block of a cancelled request is not called by default. This behavior can be changed by changing request options, as follows:

```objective-c
NSURLRequest *URLRequest = ...;
SRGRequest *request = [[SRGRequest dataRequestWithURLRequest:URLRequest session:NSURLSession.sharedSession completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    // The completion block is now called if the request is cancelled
}] requestWithOptions:SRGRequestOptionCancellationErrorsEnabled];
[request resume];
```

Other options can be added with the `|` bitwise OR operator. For example, you can use `SRGRequestOptionBackgroundCompletionEnabled`to have the completion block called on a background thread.

Other request variants exist which can automatically parse the reponse data as a JSON dictionary or array, or as an object using an arbitrary parser.

### Lifetime and cancellation

A request retains itself when running and can therefore be executed as described above, but in general you should store a reference to any request you perform so that you can cancel it when appropriate.

Consider for example a request made at the view controller level. One way to ensure that the request does not run unnecessarily if the user navigates back before the request finishes is to store a reference to the request (a weak one suffices since the request retains itself), cancelling it when the view controller is removed:

```objective-c
@interface MyViewController ()
@property (nonatomic, weak) SRGRequest *request;
@end
```

Set the request property when a refresh is performed:

```objective-c
- (void)refresh
{
    NSURLRequest *URLRequest = ...;
    SRGRequest *request = [SRGRequest dataRequestWithURLRequest:URLRequest session:NSURLSession.sharedSession completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // ...
    }];
    [request resume];
    self.request = request;
}
```

and use this reference to cancel it when the view controller disappears:

```objective-c
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (self.movingFromParentViewController || self.beingDismissed) {
        [self.request cancel];
    }
}
```

## Pagination

Pagination is a way to retrieve results in pages of constrained size, e.g. 20 items at most per page. Requesting pages starts with `SRGFirstPageRequest`, which you instantiate like usual requests, but with two blocks:

* A sizer, which provides the recipe to turn the vanilla `NSURLRequest` as parameter to constraint it to a number of items per page.
* A paginator, which provides the recipe to find the next page of content. How the location of a next page of content is received depends on the kind of service you are getting data from, usually:
    * Some services return the next link URL [in response headers](https://tools.ietf.org/html/rfc5988).
    * Other services return the next link somewhere in the response body.
    * Other services offer random access to pages of content, which means the client can build the URL of a page directly, knowing its size and its number. Though a service might provide random access to pages of content, SRG Network pagination always requires you to start with the first page of content and iterate as required, though.

Here is an example of a service for which pagination is specified with a `pageSize` parameter, while the next page of content is received in an optional `next` field found in JSON responses:

```objective-c
NSURLRequest *URLRequest = ...;
SRGFirstPageRequest *firstRequest = [SRGFirstPageRequest JSONDictionaryRequestWithURLRequest:URLRequest session:NSURLSession.sharedSession sizer:^NSURLRequest *(NSURLRequest * _Nonnull URLRequest, NSUInteger size) {
    NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:URLRequest.URL resolvingAgainstBaseURL:NO];
    URLComponents.queryItems = @[ [NSURLQueryItem queryItemWithName:@"pageSize" value:@(size).stringValue] ];
    return [NSURLRequest requestWithURL:URLComponents.URL];
} paginator:^NSURLRequest * _Nullable(NSURLRequest * _Nonnull URLRequest, NSDictionary * _Nullable JSONDictionary, NSURLResponse * _Nullable response, NSUInteger size, NSUInteger number) {
    id next = JSONDictionary[@"next"];
    NSURL *nextURL = [next isKindOfClass:NSString.class] ? [NSURL URLWithString:next] : nil;
    return nextURL ? [NSURLRequest requestWithURL:nextURL] : nil;
} completionBlock:^(NSDictionary * _Nullable JSONDictionary, SRGPage * _Nonnull page, SRGPage * _Nullable nextPage, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    // ...
}];
[firstRequest resume];
```

### Iterating through pages 

Once an `SRGFirstPageRequest` has been successfully executed, the paginator (if correctly implemented) will return a next page to its completion block if more content is available. You can then use this page to build the request for the next page of content:

```objective-c
NSURLRequest *URLRequest = ...;
__block SRGFirstPageRequest *firstRequest = nil;
firstRequest = [SRGFirstPageRequest JSONDictionaryRequestWithURLRequest:URLRequest session:NSURLSession.sharedSession sizer:^NSURLRequest *(NSURLRequest * _Nonnull URLRequest, NSUInteger size) {
    // See above
} paginator:^NSURLRequest * _Nullable(NSURLRequest * _Nonnull URLRequest, NSDictionary * _Nullable JSONDictionary, NSURLResponse * _Nullable response, NSUInteger size, NSUInteger number) {
    // See above
} completionBlock:^(NSDictionary * _Nullable JSONDictionary, SRGPage * _Nonnull page, SRGPage * _Nullable nextPage, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    // ...
    
    // Request the next page of content, if any
    if (nextPage) {
        SRGPageRequest *nextRequest = [firstRequest requestWithPage:nextPage];
        [nextRequest resume];
    }
    else {
        // Release the reference for proper deallocation
        firstRequest = nil;
    }
}];
[firstRequest resume];
```

This implementation is meant for illustration purposes mostly since it has two major drawbacks:

* Requests are performed one after another, which can be catastrophic if a lot of pages are available. Usually, you should wait until the current result set has been browsed before loading the next page (e.g. via a dedicated table view footer).
* There is no way to cancel the requests once started.
* Since page requests are generated from the first, assigned to a `__block` variable, the `__block` variable must be set to `nil` when not used anymore, so that the request can properly get deallocated.

To solve those issues and properly implement pagination support in your application, you should use a request queue.

## Request queues

You often need to perform related requests together. To make this process as straightforward as possible, the SRG Network library supplies an `SRGRequestQueue` utility class. This class avoids usual bookkeeping associated with multiple requests (e.g. having a request counter somewhere), and provides a nice way to cancel all requests at once.

A request queue is a group of requests which is considered to be running when at least one request it is associated with is running. When toggling between running and non-running states, the queue calls an optional state change block, which makes it easy to perform actions related to the global request execution (e.g. updating the user interface). During the course of request execution, the block might be called several times, as the queue might switch several times between running and non-running states.

Requests can be added at any time to an existing queue, whose state will be immediately updated accordingly. If errors are encountered along the way, requests can also report errors to the queue, so that these errors can be consolidated and reported once.

### Instantiation and lifetime

Unlike requests, queues do not automatically retain themselves when running. This would namely lead to subtle premature deallocation issues, since a queue is intended to be able to toggle several times between running and non-running states. Your code must therefore strongly reference a request queue while in use.

Consider for example requests made at the view controller level. One way to ensure that requests do not run unnecessarily if the user navigates back before the requests finish is to store a reference to a request queue, cancelling it when the view controller is removed:

```objective-c
@interface MyViewController ()
@property (nonatomic) SRGRequestQueue *requestQueue;
@end
```

Create a fresh request queue when a refresh is performed, and assign it to this property to keep it alive:

```objective-c
- (void)refresh
{
    self.requestQueue = [[SRGRequestQueue alloc] initWithStateChangeBlock:^(BOOL finished, NSError * _Nullable error) {
        if (finished) {
            // Called when the queue switches from runnning to non-running
        }
        else {
            // Called when the queue switches from non-running to running
        }
    }];

    // Add requests as needed
}
```

An optional state change block can be provided, which is called when the queue toggles between running and non-running states. The state change block can for example be used to display a spinner while the queue is running, or to reload a table of results once the queue finishes.

Once you have a queue, you can add requests to it at any time. In general, requests are added in parallel or in cascade (see below). You can also cancel a queue, which will cancel all requests related to it, e.g. when your view controller disappears:

```objective-c
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (self.movingFromParentViewController || self.beingDismissed) {
        [self.requestQueue cancel];
    }
}
```

#### Remark

Requests added to a queue do not need to be additionally retained elsewhere. They are automatically retained _with_ the queue and cancelled when the queue is cancelled. Not that requests are not internally retained _by_ the queue, which means no retain cycle will occur if you reference a queue from within a request completion block (which is the pattern enforced by error reporting, see below). No `__weak` reference to the queue is therefore required in such cases.

### Parallel requests

If a request does not depend on the result of another request, you can instantiate both requests at the same level and add them to a common queue by calling `-addRequest:resume:`:

```objective-c
- (void)refresh
{
    self.requestQueue = [[SRGRequestQueue alloc] initWithStateChangeBlock:^(BOOL finished, NSError * _Nullable error) {
        if (finished) {
            // Proceed with the results. If errors have been reported to the queue, they will be available here
        }
        else {
            // Display a spinning wheel, for example
        }
    }];
    
    NSURLRequest *URLRequest1 = ...;
    SRGRequest *request1 = [SRGRequest dataRequestWithURLRequest:URLRequest1 session:NSURLSession.sharedSession completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self.requestQueue reportError:error];
        
        // ...
    }];
    [self.requestQueue addRequest:request1 resume:YES];
    
    NSURLRequest *URLRequest2 = ...;
    SRGRequest *request2 = [SRGRequest dataRequestWithURLRequest:URLRequest2 session:NSURLSession.sharedSession completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self.requestQueue reportError:error];
        
        // ...
    }];
    [self.requestQueue addRequest:request2 resume:YES];
}
```

When adding requests to a queue, you can have them automatically started by setting the `resume` parameter to `YES`. If you set it to `NO`, you can still start the queue later by calling `-resume` on it. 

Each individual request completion block might receive an error. To propagate errors to the parent queue, completion block implementations should call `-reportError:` on the queue. You do not need to check whether the error to be reported is `nil` or not (if error is `nil`, no error will be reported). Once the queue completes, the consolidated error information, built from all errors reported to the queue when it was running, will be available. 

#### Remark

As said before, and unlike requests, queues need to be retained by some parent context to stay alive. If for example a queue is retained by `self`, like in our example above, you must weakify `self` for use in the state change block, otherwise you will create a retain cycle:

```objective-c
- (void)refresh
{
    NSURLRequest *URLRequest = ...;

    __weak __typeof(self) weakSelf = self;
    self.requestQueue = [SRGRequest dataRequestWithURLRequest:URLRequest session:NSURLSession.sharedSession completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [weakSelf doStuff];
    }];
    
    // ...
}
```

or, with the `libextobjc` framework bundled as `SRGNetwork` dependency:

```objective-c
- (void)refresh
{
    @weakify(self)
    self.requestQueue = [[SRGRequestQueue alloc] initWithStateChangeBlock:^(BOOL finished, NSError * _Nullable error) {
        @strongify(self)
        [self doStuff];
    }];
    
    // ...
}
```

### Cascading requests

If a request depends on the result of another request, you can similarly use a request queue to bind them together, for example:

```objective-c
- (void)refresh
{
    self.requestQueue = [[SRGRequestQueue alloc] initWithStateChangeBlock:^(BOOL finished, NSError * _Nullable error) {
        // ...
    }];

    NSURLRequest *URLRequest1 = ...;
    SRGRequest *request1 = [SRGRequest JSONDictionaryRequestWithURLRequest:URLRequest1 session:NSURLSession.sharedSession completionBlock:^(NSDictionary * _Nullable JSONDictionary, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            [self.requestQueue reportError:error];
            return;
        }
        
        // Extract information needed to build the next request
        // ...
        
        NSURLRequest *URLRequest2 = ...;
        SRGRequest *request2 = [SRGRequest JSONDictionaryRequestWithURLRequest:URLRequest2 session:NSURLSession.sharedSession completionBlock:^(NSDictionary * _Nullable JSONDictionary, NSURLResponse * _Nullable response, NSError * _Nullable error) {
             if (error) {
                [self.requestQueue reportError:error];
                return;
             }
        
             // ...
        }];
        [self.requestQueue addRequest:request2 resume:YES];
    }];
    [self.requestQueue addRequest:request1 resume:YES];
}
```

### Pagination and request queues

As said above, you should not immediately chain requests for pages of contents immediately, otherwise all pages would be retrieved in a single batch, which is not how pagination is supposed to work. The request for an additional page of content is namely usually related to some kind of user interaction, whether a table view was scrolled to its bottom, or the user tapped on a button to load more content. 

A single request queue can be used to implement on-demand page loading, thanks to the possibility to add a request to a queue at any time. You only need to store the next page information alongside the queue and the first page request, so that this information is available when the next page of content must be retrieved:

```objective-c
@interface MyViewController ()
@property (nonatomic) SRGRequestQueue *requestQueue;
@property (nonatomic, weak) SRGFirstPageRequest *firstRequest;
@property (nonatomic) SRGPage *nextPage;
@end
```

When a full refresh is needed, create the first request and a queue which will receive all page requests:

```objective-c
- (void)refresh
{
    self.nextPage = nil;

    self.requestQueue = [[SRGRequestQueue alloc] initWithStateChangeBlock:^(BOOL finished, NSError * _Nullable error) {
        if (finished) {
            // Consolidate the request results and display them, or deal with errors
        }
        else {
            // Display a spinning wheel, for example
        }
    }];

    SRGFirstPageRequest *firstRequest = [SRGFirstPageRequest JSONDictionaryRequestWithURLRequest:URLRequest session:NSURLSession.sharedSession sizer:^NSURLRequest *(NSURLRequest * _Nonnull URLRequest, NSUInteger size) {
        // ...
    } paginator:^NSURLRequest * _Nullable(NSURLRequest * _Nonnull URLRequest, NSDictionary * _Nullable JSONDictionary, NSURLResponse * _Nullable response, NSUInteger size, NSUInteger number) {
        // ...
    } completionBlock:^(NSDictionary * _Nullable JSONDictionary, SRGPage * _Nonnull page, SRGPage * _Nullable nextPage, NSURLResponse * _Nullable response, NSError * _Nullable error) 
        if (error) {
            [self.requestQueue reportError:error];
            return;
        }
        
        // ...
        
        self.nextPage = nextPage;
    }];
    [self.requestQueue addRequest:firstRequest resume:YES];
    self.firstRequest = firstRequest;
}
```

When you need to load the next page of content (if any is available), simply generate the next page request and add it to the queue:

```objective-c
- (void)loadNextPage
{
    if (self.nextPage) {
        SRGPageRequest *nextRequest = [self.firstRequest requestWithPage:self.nextPage];
        [self.requestQueue addRequest:nextRequest resume:YES];
    }
}
```

### Decentralized requests

The pagination example does add requests to its queue at a single place, but in a more decentralized way across a view controller implementation.

This idea can be extended to larger subsystems, as queues can be passed around your application easily, so that each subsystem can add requests to it. 

For example, you could have a view controller manage a queue, provide it to table view cells it contains when they appear, so that they can themselves add requests to it. In this example, queue management and lifecycle remains at the view controller level (which can for example properly display a loading indicator when data is still being retrieved), while requests are added in a decentralized way.

## Network activity management (iOS)

SRG Network optionally provides a way to automatically manage your device network activity indicator depending on whether requests are running or not. Call `+[SRGNetworkActivityManagement enable]` early in your application lifecycle to enable this feature.

Automatic network activity indicator management should not be enabled if already performed elsewhere, as those mechanisms would most probably interfere. In such cases, you can still decide to register a custom handler using `+[SRGNetworkActivityManagement enableWithHandler:]`, letting you choose how to respond to network activity changes.
