/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import XCTest
import Foundation

@testable import Kitura
@testable import KituraNet

class TestQuery: XCTestCase {
    
    static var allTests: [(String, (TestQuery) -> () throws -> Void)] {
        return [
            ("testQuery", testQuery),
        ]
    }
    
    override func setUp() {
        doSetUp()
    }
    
    override func tearDown() {
        doTearDown()
    }
    
    func testQuery() {
        let router = Router()
        
        router.get("strings") { request, response, next in
            XCTAssertNotNil(request.queryParameters["q"])
            XCTAssertNotNil(request.query["q"].string)
            XCTAssertEqual(request.query["q"].string, request.queryParameters["q"])
            response.status(.OK)
            next()
        }
        
        router.get("ints") { request, response, next in
            let param = request.queryParameters["q"]
            XCTAssertNotNil(param)
            XCTAssertNotNil(request.query["q"].string)
            let parameterInt = Int(param!)
            XCTAssertEqual(request.query["q"].int, parameterInt)
            response.status(.OK)
            next()
        }
        
        router.get("non_int") { request, response, next in
            let param = request.queryParameters["q"]
            XCTAssertNotNil(param)
            
            if case .null = request.query["q"].type {
                XCTFail()
            }
            
            XCTAssertNil(request.query["q"].int)
            XCTAssertNotNil(request.query["q"].string)
            XCTAssertEqual(request.query["q"].string, request.queryParameters["q"])
            
            response.status(.OK)
            next()
        }
        
        router.get("array") { request, response, next in
            XCTAssertNotNil(request.queryParameters["q[]"])
            
            if case .null = request.query["q"].type {
                XCTFail()
            }
            
            XCTAssertNil(request.query["q"].int)
            XCTAssertNil(request.query["q"].string)
            XCTAssertNotNil(request.query["q"].array)
            
            XCTAssertEqual(request.query["q"][0].int, 1)
            XCTAssertEqual(request.query["q"][1].int, 2)
            XCTAssertEqual(request.query["q"][2].int, 3)
            
            XCTAssertEqual(request.query["q", 0].int, 1)
            XCTAssertEqual(request.query["q", 1].int, 2)
            XCTAssertEqual(request.query["q", 2].int, 3)
            
            XCTAssertEqual(request.query["q", 0].int, request.query["q"][0].int)
            XCTAssertEqual(request.query["q", 1].int, request.query["q"][1].int)
            XCTAssertEqual(request.query["q", 2].int, request.query["q"][2].int)
            
            XCTAssertNil(request.query["q"][3].int)
            
            response.status(.OK)
            next()
        }
        
        router.get("dictionary") { request, response, next in
            XCTAssertNotNil(request.queryParameters["q[\"a\"]"])
            
            if case .null = request.query["q"].type {
                XCTFail()
            }
            
            XCTAssertNil(request.query["q"].int)
            XCTAssertNil(request.query["q"].string)
            XCTAssertNil(request.query["q"].array)
            XCTAssertNotNil(request.query["q"].dictionary)
            
            XCTAssertEqual(request.query["q"]["a"].int, 1)
            XCTAssertEqual(request.query["q"]["str"].string, "done")
            XCTAssertEqual(request.query["q"][1].string, "int")
            
            XCTAssertEqual(request.query["q", "a"].int, 1)
            XCTAssertEqual(request.query["q", "str"].string, "done")
            XCTAssertEqual(request.query["q", 1].string, "int")
            
            XCTAssertEqual(request.query["q", "a"].int, request.query["q"]["a"].int)
            XCTAssertEqual(request.query["q", "str"].string, request.query["q"]["str"].string)
            XCTAssertEqual(request.query["q", 1].string, request.query["q"][1].string)
            
            XCTAssertNil(request.query["q"][2].int)
            XCTAssertNil(request.query["q"]["a3"].int)
            
            response.status(.OK)
            next()
        }
        
        performServerTest(router, asyncTasks: { expectation in
            self.performRequest("get", path: "strings?q=tra-ta-ta", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                expectation.fulfill()
            })
        }, { expectation in
            self.performRequest("get", path: "ints?q=1050", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                expectation.fulfill()
            })
        }, { expectation in
            self.performRequest("get", path: "non_int?q=105ess0", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                expectation.fulfill()
            })
        }, { expectation in
            self.performRequest("get", path: "array?q[]=1&q[]=2&q[]=3", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                expectation.fulfill()
            })
        }, { expectation in
            self.performRequest("get", path: "dictionary?q[a]=1&q[str]=done&q[1]=int", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                expectation.fulfill()
            })
        })
    }
}
