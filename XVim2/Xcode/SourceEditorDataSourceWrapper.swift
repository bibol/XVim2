//
//  SourceEditorDataSourceWrapper.swift
//  XVim2
//
//  Created by Ant on 22/10/2017.
//  Copyright © 2017 Shuichiro Suzuki. All rights reserved.
//
// swiftlint:disable identifier_name
// swiftlint:disable line_length

import Cocoa

typealias InternalCharOffset = Int

@_silgen_name("seds_wrapper_call") func _positionFromInternalCharOffset (_: UnsafeRawPointer, _: InternalCharOffset, lineHint: Int) -> (XVimSourceEditorPosition)
@_silgen_name("seds_wrapper_call2") func _internalCharOffsetFromPosition (_: UnsafeRawPointer, _: XVimSourceEditorPosition) -> (Int)
@_silgen_name("seds_wrapper_call3") func _voidToVoid (_: UnsafeRawPointer)
@_silgen_name("seds_wrapper_call4") func _voidToInt(_: UnsafeRawPointer) -> (Int)
@_silgen_name("seds_wrapper_call5") func _getUndoManager(_: UnsafeRawPointer) -> (UnsafeMutableRawPointer)
@_silgen_name("seds_wrapper_call6") func _leadingWhitespaceWithForLine(_: UnsafeRawPointer, _: Int, expandTabs: Bool) -> (Int)
@_silgen_name("seds_wrapper_call7") func _intToInt(_: UnsafeRawPointer, _: Int) -> (Int)

// NOTE: global variable is automatically lazy in swift.
// Getting function address only once because function address is fixed value when after allocation.
private let fpBeginEditingTransaction
    = function_ptr_from_name("_$s12SourceEditor0ab4DataA0C20beginEditTransactionyyF")
private let fpEndEditingTransaction
    = function_ptr_from_name("_$s12SourceEditor0ab4DataA0C18endEditTransactionyyF")
private let fpPositionFromIndexLineHint
    = function_ptr_from_name("_$s12SourceEditor0ab4DataA0C30positionFromInternalCharOffset_8lineHintAA0aB8PositionVSi_SitF")
private let fpIndexFromPosition
    = function_ptr_from_name("_$s12SourceEditor0ab4DataA0C30internalCharOffsetFromPositionySiAA0abH0VF")
private let fpGetUndoManager
    = function_ptr_from_name("_$s12SourceEditor0ab4DataA0C11undoManagerAA0ab4UndoE0Cvg")
private let fpLeadingWhitespaceWidthForLine
    = function_ptr_from_name("_$s12SourceEditor0ab4DataA0C29leadingWhitespaceWidthForLine_10expandTabsS2i_SbtF")
private let fpLineCount
    = function_ptr_from_name("_$s12SourceEditor0ab4DataA0C9lineCountSivg")
private let fpLineContentLength
    = function_ptr_from_name("_$s12SourceEditor0ab4DataA0C24lineContentLengthForLineyS2iF")
private let fpLineTerminatorLength
    = function_ptr_from_name("_$s12SourceEditor0ab4DataA0C27lineTerminatorLengthForLineyS2iF")

public struct XVimLineData {
    var reserved1: Int64
    var reserved2: Int64
    var lineContentRange: NSRange
    var lineTerminatorLength: Int
    var placeholderHiddenRanges: [NSRange]
    var isHidden: Bool
}

private struct SourceEditorDataSourceInvoker {
    let contextPtr = UnsafeMutablePointer<UnsafeMutableRawPointer>.allocate(capacity: 2)

    public init?(_ dataSrc: AnyObject?, _ functionPtr: UnsafeMutableRawPointer?) {
        guard let dataSource = dataSrc,
            let functionPtr = functionPtr
            else { return nil }

        contextPtr[0] = Unmanaged.passRetained(dataSource).toOpaque()
        contextPtr[1] = functionPtr
    }

    var undoManager: AnyObject? {
        Unmanaged.fromOpaque(_getUndoManager(contextPtr).assumingMemoryBound(to: AnyObject?.self)).takeRetainedValue()
    }

    func voidToVoid() {
        _voidToVoid(contextPtr)
    }

    func voidToInt() -> Int {
        _voidToInt(contextPtr)
    }

    func intToInt(_ arg: Int) -> Int {
        _intToInt(contextPtr, arg)
    }

    func positionFromInternalCharOffset(_ pos: Int, lineHint: Int = 0) -> XVimSourceEditorPosition {
        _positionFromInternalCharOffset(contextPtr, pos, lineHint: lineHint)
    }

    func internalCharOffsetFromPosition(_ pos: XVimSourceEditorPosition) -> Int {
        _internalCharOffsetFromPosition(contextPtr, pos)
    }

    func leadingWhitespaceWidthForLine(_ line: Int, expandTabs: Bool) -> Int {
        _leadingWhitespaceWithForLine(contextPtr, line, expandTabs: expandTabs)
    }
}

class SourceEditorDataSourceWrapper: NSObject {
    private weak var sourceEditorViewWrapper: SourceEditorViewWrapper?

    private var dataSource: AnyObject? {
        sourceEditorViewWrapper?.dataSource
    }

    @objc
    public init(sourceEditorViewWrapper: SourceEditorViewWrapper) {
        self.sourceEditorViewWrapper = sourceEditorViewWrapper
    }

    @objc
    public var undoManager: AnyObject? {
        SourceEditorDataSourceInvoker(dataSource, fpGetUndoManager)?.undoManager ?? nil
    }

    @objc
    public func beginEditTransaction() {
        SourceEditorDataSourceInvoker(dataSource, fpBeginEditingTransaction)?.voidToVoid()
    }

    @objc
    public func endEditTransaction() {
        SourceEditorDataSourceInvoker(dataSource, fpEndEditingTransaction)?.voidToVoid()
    }

    @objc
    public func positionFromInternalCharOffset(_ pos: Int, lineHint: Int = 0) -> XVimSourceEditorPosition {
        SourceEditorDataSourceInvoker(dataSource, fpPositionFromIndexLineHint)?
            .positionFromInternalCharOffset(pos, lineHint: lineHint)
            ?? XVimSourceEditorPosition()
    }

    @objc
    public func internalCharOffsetFromPosition(_ pos: XVimSourceEditorPosition) -> Int {
        SourceEditorDataSourceInvoker(dataSource, fpIndexFromPosition)?
            .internalCharOffsetFromPosition(pos)
            ?? 0
    }

    @objc
    public var lineCount: Int {
        SourceEditorDataSourceInvoker(dataSource, fpLineCount)?.voidToInt() ?? 0
    }

    @objc
    public func lineContentLength(forLine: Int) -> Int {
        SourceEditorDataSourceInvoker(dataSource, fpLineContentLength)?.intToInt(forLine) ?? 0
    }

    @objc
    public func lineTerminatorLength(forLine: Int) -> Int {
        SourceEditorDataSourceInvoker(dataSource, fpLineTerminatorLength)?.intToInt(forLine) ?? 0
    }

    @objc
    public func leadingWhitespaceWidthForLine(_ line: Int, expandTabs: Bool) -> Int {
        SourceEditorDataSourceInvoker(dataSource, fpLeadingWhitespaceWidthForLine)?
            .leadingWhitespaceWidthForLine(line, expandTabs: expandTabs)
            ?? 0
    }
}
