Regarding your question about parameter passing, here's the comparison:

URL Parameters (Query String)

dartCopyurl: '${AppUrls.verifyCustomer}?mobile_number=$phoneNumber'
method: 'GET',
body: null

Body Parameters

dartCopyurl: AppUrls.verifyCustomer
method: 'POST',
body: {'mobile_number': phoneNumber}
Best Practice Recommendation:

For GET requests: Use URL parameters (Option 1)
For POST/PUT/PATCH requests: Use body parameters (Option 2)

Here's why:
URL Parameters (Option 1) is better for your case because:

It follows REST conventions - GET requests should not have a body
Better cacheability - URLs with query parameters are easier to cache
Better visibility - Parameters are visible in logs and browser history
More compatible - Some servers might ignore body in GET requests
Simpler debugging - You can test directly in a browser

Body Parameters would be better when:

Sending large amounts of data
Sending sensitive information (though HTTPS should be used regardless)
Using POST/PUT/PATCH methods
Complex data structures need to be sent
Multiple parameters with large values

Since you're doing a simple customer verification check with just a phone number:

It's a read operation (GET is appropriate)
The data is simple (single parameter)
The parameter isn't sensitive (phone numbers are often visible in URLs)