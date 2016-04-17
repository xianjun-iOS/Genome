//
//  Genome
//
//  Created by Logan Wright
//  Copyright © 2016 lowriDevs. All rights reserved.
//
//  MIT
//

// MARK: Constants

public let EmptyNode = Node.object([:])

// MARK: Context

public protocol Context {}

extension Map : Context {}
extension Node : Context {}
extension Array : Context {}
extension Dictionary : Context {}

// MARK: NodeConvertible

/**
 The underlying protocol used for all conversions. 
 
 This is the base of all Genome, where both sides of data are NodeConvertible.
 
 The Mapped object, as well as the Backing data both conform. 
 Any NodeConvertible can be turned into any other NodeConvertible type
 
 Json => Node => Object
 */
public protocol NodeConvertible {
    /**
     Initialiize the convertible with a node within a context.
     
     Context is an empty protocol to which any type can conform.
     This allows flexibility. for objects that might require access
     to a context outside of the json ecosystem
     */
    init(with node: Node, in context: Context) throws
    func toNode() throws -> Node
}

extension NodeConvertible {
    public init(with node: Node) throws {
        try self.init(with: node, in: node)
    }
}

// MARK: Node

extension Node: NodeConvertible { // Can conform to both if non-throwing implementations
    public init(with node: Node, in context: Context) {
        self = node
    }
    
    public func toNode() -> Node {
        return self
    }
}

// MARK: String

extension String: NodeConvertible {
    public func toNode() throws -> Node {
        return Node(self)
    }
    
    public init(with node: Node, in context: Context) throws {
        guard let string = node.stringValue else {
            throw log(.UnableToConvert(node: node, to: "\(String.self)"))
        }
        self = string
    }
}

// MARK: Boolean

extension Bool: NodeConvertible {
    public func toNode() throws -> Node {
        return Node(self)
    }
    
    public init(with node: Node, in context: Context) throws {
        guard let bool = node.boolValue else {
            throw log(.UnableToConvert(node: node, to: "\(Bool.self)"))
        }
        self = bool
    }
}

// MARK: UnsignedInteger

extension UInt: NodeConvertible {}
extension UInt8: NodeConvertible {}
extension UInt16: NodeConvertible {}
extension UInt32: NodeConvertible {}
extension UInt64: NodeConvertible {}

extension UnsignedInteger {
    public func toNode() throws -> Node {
        let double = Double(UIntMax(self.toUIntMax()))
        return Node(double)
    }
    
    public init(with node: Node, in context: Context) throws {
        guard let int = node.uintValue else {
            throw log(.UnableToConvert(node: node, to: "\(Self.self)"))
        }

        self.init(int.toUIntMax())
    }
}

// MARK: SignedInteger

extension Int: NodeConvertible {}
extension Int8: NodeConvertible {}
extension Int16: NodeConvertible {}
extension Int32: NodeConvertible {}
extension Int64: NodeConvertible {}

extension SignedInteger {
    public func toNode() throws -> Node {
        let double = Double(IntMax(self.toIntMax()))
        return Node(double)
    }
    
    public init(with node: Node, in context: Context) throws {
        guard let int = node.intValue else {
            throw log(.UnableToConvert(node: node, to: "\(Self.self)"))
        }

        self.init(int.toIntMax())
    }
}

// MARK: FloatingPoint

extension Float: NodeConvertibleFloatingPointType {
    public var doubleValue: Double {
        return Double(self)
    }
}

extension Double: NodeConvertibleFloatingPointType {
    public var doubleValue: Double {
        return Double(self)
    }
}

public protocol NodeConvertibleFloatingPointType: NodeConvertible {
    var doubleValue: Double { get }
    init(_ other: Double)
}

extension NodeConvertibleFloatingPointType {
    public func toNode() throws -> Node {
        return Node(doubleValue)
    }
    
    public init(with node: Node, in context: Context) throws {
        guard let double = node.doubleValue else {
            throw log(.UnableToConvert(node: node, to: "\(Self.self)"))
        }
        self.init(double)
    }
}

// MARK: Convenience

extension Node {
    public init(_ dictionary: [String : NodeConvertible]) throws {
        var mutable: [String : Node] = [:]
        try dictionary.forEach { key, value in
            mutable[key] = try value.toNode()
        }
        self = .object(mutable)
    }
}
