//
//  ConcurrentCompactMap.swift
//  PixelRoom
//
//  Created by Ross Kimes on 3/6/21.
//

import Dispatch

extension Array {
    
    // This has the same output as compactMap, but runs each element concurrently.
    // This is good to use if the transform is expensive.
    //
    // Using this approach could have the side effect of using more memory
    // (since the data from multiple images could be loaded at one time).
    // A quick check in the memory debugger did not show it to be a problem in this
    // case, but we would want to investigate this more before commiting to this approach.
    //
    // This func wac adapted from sample code from
    // https://talk.objc.io/episodes/S01E90-concurrent-map.
    func concurrentCompactMap<B>(_ transform: @escaping (Element) -> B?) -> [B] {
        var result = Array<B?>(repeating: nil, count: count)
        let q = DispatchQueue(label: "sync queue")
        DispatchQueue.concurrentPerform(iterations: count) { idx in
            let element = self[idx]
            let transformed = transform(element)
            q.sync {
                result[idx] = transformed
            }
        }
        return result.compactMap { $0 }
    }
}
