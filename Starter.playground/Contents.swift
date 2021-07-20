import UIKit
import Combine

var subscriptions = Set<AnyCancellable>()

example(of: "prepend(Output...)") {
    // 1 create a publisher 
    let publisher = [3, 4].publisher
    
    // 2 Use prepend to add numbers 1, 2 before the publisher owns values
    publisher
        .prepend(1, 2)
        .prepend(-1, 0)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}


example(of: "prepend(Sequence)") {
    // 1
    let publisher = [5, 6, 7].publisher
        
        // 2
        .prepend([3, 4])
        .prepend(Set(1...2))
        .prepend(stride(from: 6, to: 11, by: 2)) // Strideable conform to sequence. We can use it
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
    
}

example(of: "prepend(Publisher)") {
    // 1 create 2 publishers
    let publisher1 = [3, 4].publisher
    let publisher2 = [1, 2].publisher
    
    // 2 prepend publisher2 at the begining of publisher 1
    publisher1
        .prepend(publisher2)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
    
}

example(of: "prepend(Publisher) #2") {
    // 1 Create two publisher
    let publisher1 = [3, 4].publisher
    let publisher2 = PassthroughSubject<Int, Never>()
    
    // 2 Prepend subject before publisher1
    publisher1
        .prepend(publisher2)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
    
    // 3 send value to publisher 2
    publisher2.send(1)
    publisher2.send(2)
    publisher2.send(completion: .finished)
}

example(of: "append(Output...)") {
    let publisher = [1].publisher
    
    publisher
        .append(2, 3)
        .append(4)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "append(Output...) #2") {
    // 1 create publisher passtroughSubject so we can send value manually
    let publisher = PassthroughSubject<Int, Never>()
    
    publisher
        .append(3, 4)
        .append(5)
        .sink(receiveValue: { print($0)} )
        .store(in: &subscriptions)
    
    // 2 Send 1 and 2 to passtroughSubject
    publisher.send(1)
    publisher.send(2)
    publisher.send(completion: .finished)
}

example(of: "append(Sequence)") {
    // 1 Create publisher
    let publisher = [1, 2, 3].publisher
    
    publisher
        .append([4, 5])
        .append(Set([6, 7]))
        .append(stride(from: 8, to: 11, by: 2))
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "append(Publisher)") {
    // create two publisher
    let publisher1 = [1, 2].publisher
    let publisher2 = [3, 4].publisher
    
    // append publisher 2 to publisher 1
    publisher1
        .append(publisher2)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "switchToLatest") {
    // 1 create passthrough subject accept int and no errors
    let publisher1 = PassthroughSubject<Int, Never>()
    let publisher2 = PassthroughSubject<Int, Never>()
    let publisher3 = PassthroughSubject<Int, Never>()
    
    // 2 Create passthroughSubject subject that accept other passthroughSubject
    let publishers = PassthroughSubject<PassthroughSubject<Int, Never>, Never>()
    
    // 3 switchToLatest so every time we send different publisher
    publishers
        .switchToLatest()
        .sink(receiveCompletion: { _ in print("Completed") },
              receiveValue: { print($0) })
        .store(in: &subscriptions)
    
    // 4  send value to publisher 1
    publishers.send(publisher1)
    publisher1.send(1)
    publisher1.send(2)
    
    // 5 send value to publisher 2
    publishers.send(publisher2)
    publisher1.send(3)
    publisher2.send(4)
    publisher2.send(5)
    
    // 6 send value to publisher 3
    publishers.send(publisher3)
    publisher2.send(6)
    publisher3.send(7)
    publisher3.send(8)
    publisher3.send(9)
    
    // 7 send completion event to complete all actives subscription
    publisher3.send(completion: .finished)
    publishers.send(completion: .finished)
}


//example(of: "switchToLatest - Network request") {
//    let url = URL(string: "https://source.unsplash.com/random")!
//
//    // 1 Define methode which pergorm request to fetch random image
//    func getImage() -> AnyPublisher<UIImage?, Never> {
//        URLSession.shared
//            .dataTaskPublisher(for: url)
//            .map { data, _ in UIImage(data: data) }
//            .print("image")
//            .replaceError(with: nil)
//            .eraseToAnyPublisher()
//    }
//
//    // 2  Create Passtrough subject to simulate taps
//    let taps = PassthroughSubject<Void, Never>()
//
//    taps
//        .map { _ in getImage() } // 3 Upon a button tap map new network request. This transform Void -> UIImage
//        .switchToLatest() // 4 switchToLatest to emit values and cancel anyprevious subscription
//        .sink(receiveValue: { _ in })
//        .store(in: &subscriptions)
//
//    // 5 simulate 3 delayed buttons
//    taps.send()
//
//    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//        taps.send()
//    }
//
//    DispatchQueue.main.asyncAfter(deadline: .now() + 3.1) {
//        taps.send()
//    }
//}

example(of: "Merge(with:)") {
    // 1 create two passthrough subject
    let publisher1 = PassthroughSubject<Int, Never>()
    let publisher2 = PassthroughSubject<Int, Never>()

    
    // 2 Merge publisher 1 to 2
    // Combine offer overloads that let you merge up to eight differents publishers.
    publisher1
        .merge(with: publisher2)
        .sink(receiveCompletion: { _ in print("Completed") },
              receiveValue: { print($0) })
        .store(in: &subscriptions)

    
    // 3 add values to publisher
    publisher1.send(1)
    publisher1.send(2)
    
    publisher2.send(3)
    
    publisher1.send(4)
    
    publisher2.send(5)
    
    // 4 send completion to publisher
    publisher1.send(completion: .finished)
    publisher2.send(completion: .finished)
}


example(of: "combineLatest") {
    // 1
    let publisher1 = PassthroughSubject<Int, Never>()
    let publisher2 = PassthroughSubject<String, Never>()
    
   
}

// Copyright (c) 2020 Razeware LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
// distribute, sublicense, create a derivative work, and/or sell copies of the
// Software in any work that is designed, intended, or marketed for pedagogical or
// instructional purposes related to programming, coding, application development,
// or information technology.  Permission for such use, copying, modification,
// merger, publication, distribution, sublicensing, creation of derivative works,
// or sale is expressly withheld.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

